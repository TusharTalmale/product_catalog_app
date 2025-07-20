import 'package:flutter/material.dart';
import 'package:product_catalog_app/screens/add_product.dart';
import 'package:product_catalog_app/screens/my_custom_product_screen.dart';
import 'package:product_catalog_app/utils/view_mode.dart';
import 'package:product_catalog_app/widget/bottom_nav_bar.dart';
import 'package:product_catalog_app/widget/custom_appbar.dart';
import 'package:product_catalog_app/widget/product_grid_view.dart';
import 'package:product_catalog_app/widget/product_list_view.dart';
import 'package:provider/provider.dart';
import 'package:product_catalog_app/providers/product_provider.dart';
import 'package:product_catalog_app/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  final int initialTabIndex;
  const HomeScreen({super.key, this.initialTabIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _bottomNavController;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _bottomNavController = TabController(
        length: 4, vsync: this, initialIndex: widget.initialTabIndex);

    _bottomNavController.addListener(() {
      if (!_bottomNavController.indexIsChanging) {
        final productProvider =
            Provider.of<ProductProvider>(context, listen: false);
        switch (_bottomNavController.index) {
          case 0: // Home tab (All Products)
            productProvider.resetFilters(); // Reset all filters for home view
            productProvider
                .setShowFavoritesOnly(false); // Ensure favorites filter is off
            _searchController.clear(); // Clear search bar
            productProvider.setSearchQuery('');
            break;
          case 1: // Favorites tab
            productProvider.resetFilters(); // Reset other filters
            productProvider
                .setShowFavoritesOnly(true); // Ensure favorites filter is on
            _searchController.clear(); // Clear search bar
            productProvider.setSearchQuery('');
            break;
          case 2: // Add Item tab
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddProductScreen(
                  initialTabIndex: 2,
                  onTabSelected: (index) {
                    _bottomNavController.animateTo(index);
                  },
                ),
              ),
            ); 
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _bottomNavController.animateTo(0);
            });
            break;
          case 3:
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const MyCustomProductsScreen()));
            // Reset to home tab after navigating
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _bottomNavController.animateTo(0);
            });
            break;
        }
      }
    });

    // Initial load and filter application based on initialTabIndex
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      if (widget.initialTabIndex == 1) {
        // If starting on Favorites tab
        productProvider.setShowFavoritesOnly(true);
      } else {
        productProvider.resetFilters();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _bottomNavController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    Provider.of<ProductProvider>(context, listen: false)
        .setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: CustomHomeAppBar(
        searchController: _searchController,
        onSearchChanged: _onSearchChanged,
        title : _bottomNavController.index == 0 ? 'Product Catalog' : 'My Fav Items' ,
      )
       ,
      body: Column(
        children: [
          Expanded(
            child: _buildProductContent(productProvider),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _bottomNavController.index,
        onItemSelected: (index) {
          _bottomNavController.animateTo(index);
        },
      ),
    );
  }

  Widget _buildProductContent(ProductProvider productProvider) {
    if (productProvider.isLoading && productProvider.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productProvider.errorMessage != null &&
        productProvider.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(kPaddingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                productProvider.errorMessage!,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kPaddingM),
              ElevatedButton(
                onPressed: () {
                  productProvider.loadInitialData();
                  productProvider.clearErrorMessage();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (productProvider.products.isEmpty) {
      return Center(
        child: Text(
          'No products found matching your criteria.',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return productProvider.viewMode == ViewMode.grid
        ? const ProductGridView()
        : const ProductListView();
  }
}
