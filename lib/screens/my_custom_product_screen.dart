import 'dart:io';
import 'package:flutter/material.dart';
import 'package:product_catalog_app/screens/add_product.dart';
import 'package:product_catalog_app/widget/product_card.dart';
import 'package:provider/provider.dart';
import 'package:product_catalog_app/models/product_model.dart';
import 'package:product_catalog_app/providers/product_provider.dart';
import 'package:product_catalog_app/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

// Local filter states for this screen
enum MyItemsViewMode { grid, list }

class MyCustomProductsScreen extends StatefulWidget {
   final int initialTabIndex;
  final void Function(int)? onTabSelected;
  const MyCustomProductsScreen({super.key ,  this.initialTabIndex =0 ,  this.onTabSelected});

  @override
  State<MyCustomProductsScreen> createState() => _MyCustomProductsScreenState();
}

class _MyCustomProductsScreenState extends State<MyCustomProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Logger _logger = Logger();

  MyItemsViewMode _viewMode = MyItemsViewMode.grid; // Local view mode
  String _localSearchQuery = '';
  String? _localSelectedCategory;
  RangeValues _localPriceRange = const RangeValues(0, 1000);
  double _localMaxPrice = 1000;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Initialize local max price from global provider's max price
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      setState(() {
        _localMaxPrice = productProvider.maxPrice;
        _localPriceRange = RangeValues(0, _localMaxPrice);
      });
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _localSearchQuery = _searchController.text.toLowerCase();
    });
  }

  void _setLocalSelectedCategory(String? category) {
    setState(() {
      _localSelectedCategory = category;
    });
  }

  void _setLocalPriceRange(RangeValues range) {
    setState(() {
      _localPriceRange = range;
    });
  }

  void _resetLocalFilters() {
    _searchController.clear();
    setState(() {
      _localSearchQuery = '';
      _localSelectedCategory = null;
      _localPriceRange = RangeValues(0, _localMaxPrice);
    });
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == MyItemsViewMode.grid ? MyItemsViewMode.list : MyItemsViewMode.grid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: PreferredSize(
      preferredSize: const Size.fromHeight(110), // Adjust height as needed
      child: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'My Custom Items',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // To align with leading icon
                ],
              ),
              // Search Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => _onSearchChanged(),
                        decoration: InputDecoration(
                          hintText: 'Search my items...',
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.white70),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white24,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          hintStyle: const TextStyle(color: Colors.white70),
                        ),
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Filter button
                    IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: (_localSelectedCategory != null ||
                                _localPriceRange.start > 0 ||
                                _localPriceRange.end < _localMaxPrice)
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.white,
                      ),
                      tooltip: 'Filter My Items',
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => _LocalFilterBottomSheet(
                            availableCategories: Provider.of<ProductProvider>(context, listen: false).availableCategories,
                            initialSelectedCategory: _localSelectedCategory,
                            initialPriceRange: _localPriceRange,
                            maxPrice: _localMaxPrice,
                            onApplyFilters: (category, priceRange) {
                              _setLocalSelectedCategory(category);
                              _setLocalPriceRange(priceRange);
                            },
                            onResetFilters: _resetLocalFilters,
                          ),
                        );
                      },
                    ),
                    // View toggle
                    IconButton(
                      icon: Icon(
                        _viewMode == MyItemsViewMode.grid ? Icons.view_list : Icons.grid_on,
                        color: Colors.white,
                      ),
                      tooltip: _viewMode == MyItemsViewMode.grid ? 'List View' : 'Grid View',
                      onPressed: _toggleViewMode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
      ),
    ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          // Apply local filters to customProducts
          List<Product> filteredCustomProducts = productProvider.customProducts.where((product) {
            final query = _localSearchQuery;
            final matchesSearch = product.title.toLowerCase().contains(query) ||
                                  product.description.toLowerCase().contains(query) ||
                                  product.category.toLowerCase().contains(query);

            final matchesCategory = _localSelectedCategory == null ||
                                    _localSelectedCategory!.isEmpty ||
                                    product.category.toLowerCase() == _localSelectedCategory!.toLowerCase();

            final matchesPrice = product.price >= _localPriceRange.start &&
                                 product.price <= _localPriceRange.end;

            return matchesSearch && matchesCategory && matchesPrice;
          }).toList();

          if (productProvider.isLoading && filteredCustomProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.errorMessage != null && filteredCustomProducts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(kPaddingM),
                child: Text(
                  productProvider.errorMessage!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (filteredCustomProducts.isEmpty) {
            return Center(
              child: Text(
                'No custom products found matching your criteria.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            );
          }

          if (_viewMode == MyItemsViewMode.grid) {
            return GridView.builder(
              padding: const EdgeInsets.all(kPaddingS),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: kPaddingS,
                mainAxisSpacing: kPaddingS,
                childAspectRatio: kProductCardAspectRatio,
              ),
              itemCount: filteredCustomProducts.length,
              itemBuilder: (context, index) {
                final product = filteredCustomProducts[index];
                return ProductCard(
                  product: product,
                  onToggleFavorite: () => productProvider.toggleFavorite(product),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/detail',
                      arguments: product,
                    );
                  },
                );
              },
            );
          } else { // MyItemsViewMode.list
            return ListView.builder(
              padding: const EdgeInsets.all(kPaddingS),
              itemCount: filteredCustomProducts.length,
              itemBuilder: (context, index) {
                final product = filteredCustomProducts[index];
                return _MyCustomProductListItem( // New custom list item for this screen
                  product: product,
                  onEdit: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddProductScreen(productToEdit: product),
                      ),
                    );
                  },
                  onDelete: () => _confirmDelete(context, productProvider, product),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/detail',
                      arguments: product,
                    );
                  },
                );
              },
            );
          }
        },
        
      ),
      
    );
  }

  Future<void> _confirmDelete(BuildContext context, ProductProvider productProvider, Product product) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "${product.title}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await productProvider.deleteCustomProduct(product);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.title} deleted successfully!')),
          );
        }
      } catch (e) {
        _logger.e('Error deleting product from My Custom Items screen: $e', error: e);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete product: ${e.toString()}')),
          );
        }
      }
    }
  }
}

// Local Filter Bottom Sheet for MyCustomProductsScreen
class _LocalFilterBottomSheet extends StatefulWidget {
  final Set<String> availableCategories;
  final String? initialSelectedCategory;
  final RangeValues initialPriceRange;
  final double maxPrice;
  final Function(String?, RangeValues) onApplyFilters;
  final VoidCallback onResetFilters;

  const _LocalFilterBottomSheet({
    required this.availableCategories,
    required this.initialSelectedCategory,
    required this.initialPriceRange,
    required this.maxPrice,
    required this.onApplyFilters,
    required this.onResetFilters,
  });

  @override
  State<_LocalFilterBottomSheet> createState() => _LocalFilterBottomSheetState();
}

class _LocalFilterBottomSheetState extends State<_LocalFilterBottomSheet> {
  String? _tempSelectedCategory;
  RangeValues? _tempPriceRange;

  @override
  void initState() {
    super.initState();
    _tempSelectedCategory = widget.initialSelectedCategory;
    _tempPriceRange = widget.initialPriceRange;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kPaddingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter My Items',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: kPaddingL, thickness: 1.5),

          // Category Filter
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: kPaddingS),
          Wrap(
            spacing: kPaddingS,
            runSpacing: kPaddingS,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _tempSelectedCategory == null || _tempSelectedCategory!.isEmpty,
                onSelected: (selected) {
                  setState(() {
                    _tempSelectedCategory = selected ? null : _tempSelectedCategory;
                  });
                },
                selectedColor: Theme.of(context).chipTheme.selectedColor,
                backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                labelStyle: _tempSelectedCategory == null || _tempSelectedCategory!.isEmpty
                    ? Theme.of(context).chipTheme.secondaryLabelStyle
                    : Theme.of(context).chipTheme.labelStyle,
                shape: Theme.of(context).chipTheme.shape,
              ),
              ...widget.availableCategories.map((category) {
                return ChoiceChip(
                  label: Text(category),
                  selected: _tempSelectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _tempSelectedCategory = selected ? category : null;
                    });
                  },
                  selectedColor: Theme.of(context).chipTheme.selectedColor,
                  backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                  labelStyle: _tempSelectedCategory == category
                      ? Theme.of(context).chipTheme.secondaryLabelStyle
                      : Theme.of(context).chipTheme.labelStyle,
                  shape: Theme.of(context).chipTheme.shape,
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: kPaddingL),

          // Price Range Filter
          Text(
            'Price Range',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '\$${_tempPriceRange!.start.toStringAsFixed(0)} - \$${_tempPriceRange!.end.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          RangeSlider(
            values: _tempPriceRange!,
            min: 0,
            max: widget.maxPrice,
            divisions: (widget.maxPrice / 10).round().clamp(1, 100),
            labels: RangeLabels(
              _tempPriceRange!.start.toStringAsFixed(0),
              _tempPriceRange!.end.toStringAsFixed(0),
            ),
            onChanged: (newRange) {
              setState(() {
                _tempPriceRange = newRange;
              });
            },
          ),
          const SizedBox(height: kPaddingL),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onResetFilters();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
                    padding: const EdgeInsets.symmetric(vertical: kPaddingS),
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: kPaddingS),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilters(_tempSelectedCategory, _tempPriceRange!);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
                    padding: const EdgeInsets.symmetric(vertical: kPaddingS),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// New Custom Product List Item for MyCustomProductsScreen (with edit/delete buttons)
class _MyCustomProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final Logger _logger = Logger();

   _MyCustomProductListItem({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: kPaddingS, horizontal: kPaddingS),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(kPaddingS),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(kBorderRadius / 2),
                child: Image.file(
                  File(product.image),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    _logger.e('Error loading custom product image for list: ${product.image}', error: error);
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: Icon(Icons.broken_image, size: 40, color: Colors.grey[600]),
                    );
                  },
                ),
              ),
              const SizedBox(width: kPaddingM),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    if (product.createdAt != null)
                      Text(
                        'Created: ${DateFormat('yyyy-MM-dd').format(product.createdAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                      ),
                    if (product.lastEditedAt != null)
                      Text(
                        'Edited: ${DateFormat('yyyy-MM-dd').format(product.lastEditedAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                      ),
                  ],
                ),
              ),
              // Action Buttons
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Edit Product',
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete Product',
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
