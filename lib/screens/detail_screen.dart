import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:product_catalog_app/screens/add_product.dart';
import 'package:product_catalog_app/widget/product_card.dart';
import 'package:provider/provider.dart';
import 'package:product_catalog_app/models/product_model.dart';
import 'package:product_catalog_app/providers/product_provider.dart';
import 'package:product_catalog_app/utils/constants.dart';
import 'package:logger/logger.dart';

class DetailScreen extends StatelessWidget {
  final Product product; // The initial product passed to the screen
  final Logger _logger = Logger();

  // Constructor now takes a Key and the required Product
  DetailScreen({super.key, required this.product});

  // Function to confirm product deletion
  Future<void> _confirmDelete(BuildContext context, Product productToDelete) async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "${productToDelete.title}"? This action cannot be undone.'),
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
        await productProvider.deleteCustomProduct(productToDelete);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${productToDelete.title} deleted successfully!')),
          );
          // Pop the detail screen after successful deletion
          Navigator.of(context).pop();
        }
      } catch (e) {
        _logger.e('Error deleting product from detail screen: $e', error: e);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete product: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen for changes in ProductProvider
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final Product? currentProduct = productProvider.products.firstWhere(
          (p) => p.id == product.id && p.isCustom == product.isCustom,
          orElse: () => product, // Fallback to initial product if not found (e.g., deleted)
        );

        if (currentProduct == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator())); // Show loading while popping
        }

        // Filter out the current product and get related ones by category
        final List<Product> relatedProducts = productProvider.products
            .where((p) => p.category == currentProduct.category && p.id != currentProduct.id)
            .take(10) 
            .toList();

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              currentProduct.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis, 
              
            ),
            actions: [
              if (currentProduct.isCustom) ...[
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  tooltip: 'Edit Product',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddProductScreen(productToEdit: currentProduct),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  tooltip: 'Delete Custom Product',
                  onPressed: () => _confirmDelete(context, currentProduct),
                ),
              ],
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(kPaddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Container
                Center(
                  child: Container(
                    // width: double.infinity, // Take full available width
                    width: 300,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, 
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      child: currentProduct.isCustom
                          ? Image.file(
                              File(currentProduct.image),
                              fit: BoxFit.cover, // Cover the container
                              errorBuilder: (context, error, stackTrace) {
                                _logger.e('Error loading custom product image on detail screen: ${currentProduct.image}', error: error);
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.broken_image, size: 100, color: Colors.grey[600]),
                                );
                              },
                            )
                          : CachedNetworkImage(
                              imageUrl: currentProduct.image,
                              fit: BoxFit.cover, // Cover the container
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                              ),
                              errorWidget: (context, url, error) {
                                _logger.e('Error loading network image on detail screen: $url', error: error);
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey[600]),
                                );
                              },
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: kPaddingL),

                // Product Title & Favorite Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        currentProduct.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        currentProduct.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: currentProduct.isFavorite ? Colors.red : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        size: 30,
                      ),
                      onPressed: () => productProvider.toggleFavorite(currentProduct), // Pass the currentProduct
                    ),
                  ],
                ),
                const SizedBox(height: kPaddingS),

                // Price and Category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${currentProduct.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: kPaddingS, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(kBorderRadius / 2),
                      ),
                      child: Text(
                        currentProduct.category,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kPaddingM),

                // Rating (for API products)
                if (!currentProduct.isCustom) ...[
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(
                        '${currentProduct.rating.rate.toStringAsFixed(1)} (${currentProduct.rating.count} reviews)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: kPaddingM),
                ],

                // Description
                Text(
                  currentProduct.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: kPaddingL),

                // Dates (for custom products)
                if (currentProduct.isCustom) ...[
                  Text(
                    'Created At: ${currentProduct.createdAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(currentProduct.createdAt!) : 'N/A'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last Edited At: ${currentProduct.lastEditedAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(currentProduct.lastEditedAt!) : 'N/A'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  const SizedBox(height: kPaddingL),
                ],

                // Related Products Section
                if (relatedProducts.isNotEmpty) ...[
                  Text(
                    'Related Products',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: kPaddingM),
                  SizedBox(
                    height: 220, // Fixed height for horizontal scroll view
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: relatedProducts.length,
                      itemBuilder: (context, index) {
                        final relatedProduct = relatedProducts[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: kPaddingS),
                          child: SizedBox(
                            width: 150, // Fixed width for related product cards
                            child: ProductCard(
                              product: relatedProduct,
                              onToggleFavorite: () => productProvider.toggleFavorite(relatedProduct),
                              onTap: () {
                                Navigator.of(context).pushReplacementNamed( // Use pushReplacementNamed to replace current detail screen
                                  '/detail',
                                  arguments: relatedProduct,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
