import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:product_catalog_app/models/product_model.dart';
import 'package:product_catalog_app/models/custom_product_model.dart';
import 'package:product_catalog_app/services/api_service.dart';
import 'package:product_catalog_app/services/database_service.dart';
import 'package:product_catalog_app/services/image_helper.dart';
import 'package:product_catalog_app/utils/view_mode.dart';

class ProductProvider with ChangeNotifier {
  final ApiService apiService;
  final DatabaseService databaseService;
  final ImageHelper imageHelper;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
//filter
  bool _showFavoritesOnly = false;
  String _searchQuery = '';
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 1000);
  double _maxPrice = 1000;

  ThemeMode _themeMode = ThemeMode.system;
  ViewMode _viewMode = ViewMode.grid;

//generators
  List<Product> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get showFavoritesOnly => _showFavoritesOnly;
  String get searchQuery => _searchQuery;
  ThemeMode get themeMode => _themeMode;
  String? get selectedCategory => _selectedCategory;
  RangeValues get priceRange => _priceRange;
  double get maxPrice => _maxPrice;
  ViewMode get viewMode => _viewMode;

  List<Product> get customProducts =>
      _allProducts.where((p) => p.isCustom).toList();
  List<Product> get favoriteProducts =>
      _allProducts.where((p) => p.isFavorite).toList();
  
  //all categories
  Set<String> get availableCategories {
    final categories = _allProducts.map((p) => p.category).toSet();
    return categories;
  }

  ProductProvider({
    required this.apiService,
    required this.databaseService,
    required this.imageHelper,
  });

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allProducts.clear();

      // Load custom products first
      await _loadCustomProducts();

      // Check internet connectivity and fetch API products or favorite API products
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        _errorMessage = 'No internet connection. Showing offline data.';
        final favoriteApiProducts =
            await databaseService.getAllFavoriteProducts();
        _allProducts.addAll(favoriteApiProducts.where((p) => !p.isCustom));
      } else {
        await _fetchApiProducts();
      }
      _calculateMaxPrice();
    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
    } finally {
      _isLoading = false;
      _updateFilteredProducts();
      notifyListeners();
    }
  }

  Future<void> _fetchApiProducts() async {
    try {
      final apiProducts = await apiService.getProducts();

      final favoriteApiIds = await databaseService.getFavoriteProductIds();

      final productsWithFavorites = apiProducts.map((product) {
        return product.copyWith(
          isFavorite: favoriteApiIds.contains(product.id),
          isCustom: false,
        );
      }).toList();

      // Remove any existing API products from _allProducts before adding new ones
      _allProducts.removeWhere((p) => !p.isCustom);
      _allProducts.addAll(productsWithFavorites);
    } catch (e) {
      _errorMessage = 'Failed to fetch online products. ${e.toString()}';
    }
  }

  Future<void> _loadCustomProducts() async {
    try {
      final customProducts = await databaseService.getCustomProducts();

      final convertedProducts =
          customProducts.map((cp) => cp.toProduct()).toList();
      _allProducts.removeWhere((p) => p.isCustom);
      _allProducts.addAll(convertedProducts);
    } catch (e) {
      _errorMessage = 'Failed to load local products: ${e.toString()}';
    }
  }

  void _calculateMaxPrice() {
    if (_allProducts.isNotEmpty) {
      _maxPrice = _allProducts
          .map((p) => p.price)
          .reduce((curr, next) => curr > next ? curr : next);
      _maxPrice = (_maxPrice * 1.2).ceilToDouble();
      if (_maxPrice < 100) _maxPrice = 100;
      _priceRange =  RangeValues(0, _maxPrice);
    } else {
      _maxPrice = 1000;
      _priceRange = const RangeValues(0, 1000);
    }
  }

  Future<void> toggleFavorite(Product product) async {
    try {
      final index = _allProducts.indexWhere(
          (p) => p.id == product.id && p.isCustom == product.isCustom);
      if (index != -1) {
        final updatedProduct =
            product.copyWith(isFavorite: !product.isFavorite);
        _allProducts[index] = updatedProduct;

        if (updatedProduct.isFavorite) {
          await databaseService.addFavoriteProduct(updatedProduct);
        } else {
          await databaseService.removeFavoriteProduct(
              updatedProduct.id, updatedProduct.isCustom);
        }
        _updateFilteredProducts();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update favorite status: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> addCustomProduct({
    required String title,
    required String description,
    required double price,
    required String category,
    
    required String imagePath,
    String? rate,
    String? count,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final savedImagePath =
          await imageHelper.saveImageToAppDirectory(imagePath);

      final now = DateTime.now();
      final newCustomProduct = CustomProduct(
        title: title,
        description: description,
        price: price,
        category: category,
        imagePath: savedImagePath,
        
        createdAt: now,
        lastEditedAt: now,
      );

      final id = await databaseService.addCustomProduct(newCustomProduct);
      final productToAdd = newCustomProduct.copyWith(id: id).toProduct();
      _allProducts.add(productToAdd);

      _updateFilteredProducts();
    } catch (e) {
      _errorMessage = 'Failed to add custom product: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCustomProduct({
    required int id,
    required String title,
    required String description,
    required double price,
    required String category,
    required String? newImagePath,
    required String currentImagePath,
    required DateTime createdAt,
    required bool isFavorite,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String finalImagePath = currentImagePath;
      if (newImagePath != null &&
          newImagePath.isNotEmpty &&
          newImagePath != currentImagePath) {
        // Delete old image only if a new one is provided and it's different
        await imageHelper.deleteImage(currentImagePath);
        finalImagePath =
            await imageHelper.saveImageToAppDirectory(newImagePath);
      }

      final now = DateTime.now();
      final updatedCustomProduct = CustomProduct(
        id: id,
        title: title,
        description: description,
        price: price,
        category: category,
        imagePath: finalImagePath,
        createdAt: createdAt,
        lastEditedAt: now,
        isFavorite: isFavorite,
      );

      await databaseService.updateCustomProduct(updatedCustomProduct);

      final index = _allProducts.indexWhere((p) => p.id == id && p.isCustom);
      if (index != -1) {
        _allProducts[index] = updatedCustomProduct.toProduct();
      }

      _updateFilteredProducts();
    } catch (e) {
      _errorMessage = 'Failed to update custom product: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCustomProduct(Product product) async {
    if (!product.isCustom) {
      _errorMessage = 'Only user-added products can be deleted.';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await databaseService.deleteCustomProduct(product.id);
      await imageHelper.deleteImage(product.image);
      _allProducts.removeWhere((p) => p.id == product.id && p.isCustom);
      _updateFilteredProducts();
    } catch (e) {
      _errorMessage = 'Failed to delete product: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// --- Filtering and Searching ---

  void toggleShowFavorites() {
    _showFavoritesOnly = !_showFavoritesOnly;
    _updateFilteredProducts();
    notifyListeners();
  }
 void setShowFavoritesOnly(bool value) {
    if (_showFavoritesOnly != value) {
      _showFavoritesOnly = value;
      _updateFilteredProducts();
      notifyListeners();
    }
  }
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _updateFilteredProducts();
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    _updateFilteredProducts();
    notifyListeners();
  }
  
  void setPriceRange(RangeValues range) {
    _priceRange = range;
    _updateFilteredProducts();
    notifyListeners();
  }


  void resetFilters() {
    _searchQuery = '';
    _showFavoritesOnly = false;
    _selectedCategory = null;
    _priceRange = RangeValues(0, _maxPrice); // Reset to full range
    _updateFilteredProducts();
    notifyListeners();
  }

  void _updateFilteredProducts() {
    List<Product> tempProducts = List.from(_allProducts);

    // 1. Apply favorites filter
    if (_showFavoritesOnly) {
      tempProducts =
          tempProducts.where((product) => product.isFavorite).toList();
    }

    // 2. Apply multi-field search filter (title, description, category)
    if (_searchQuery.isNotEmpty) {
      tempProducts = tempProducts.where((product) {
        final query = _searchQuery;
        return product.title.toLowerCase().contains(query) ||
            product.description.toLowerCase().contains(query) ||
            product.category.toLowerCase().contains(query);
      }).toList();
    }
    // 3. Apply category filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      tempProducts = tempProducts
          .where((product) =>
              product.category.toLowerCase() ==
              _selectedCategory!.toLowerCase())
          .toList();
    }

    // 4. Apply price range filter
    tempProducts = tempProducts
        .where((product) =>
            product.price >= _priceRange.start &&
            product.price <= _priceRange.end)
        .toList();

    // 5. Sort the products (e.g., by title alphabetically)
    tempProducts
        .sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    _filteredProducts = tempProducts;
  }

  /// --- Theme Management ---

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
