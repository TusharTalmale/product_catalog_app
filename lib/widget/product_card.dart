import 'dart:io';
import 'package:flutter/material.dart';
import 'package:product_catalog_app/models/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:product_catalog_app/utils/constants.dart'; // For caching network images

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onToggleFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Stack(
                children: [
                 Center(
                   child: Container(
                      // width: double.infinity, // Take full available width
                      height: 140, 
                     
                      child: product.isCustom
                          ? Image.file(
                              File(product.image),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.broken_image_rounded,
                                    size: 50,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            )
                          : CachedNetworkImage(
                              imageUrl: product.image,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                      color:
                                          Theme.of(context).colorScheme.primary)),
                              errorWidget: (context, url, error) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image_not_supported,
                                      size: 50, color: Colors.grey[600]),
                                );
                              },
                            ),
                    ),
                 ),

                  // Favorite Icon Button
                  Positioned(
                    top: kPaddingS,
                    right: kPaddingS,
                    child: Container(
                      // Wrap in container for a subtle background behind icon
                      decoration: BoxDecoration(
                        color:
                            Colors.black54, // Semi-transparent black background
                        borderRadius: BorderRadius.circular(kBorderRadius / 2),
                      ),
                      child: IconButton(
                        icon: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: product.isFavorite
                              ? Colors.red
                              : Colors.white, // White outline for non-favorite
                          size: 24,
                        ),
                        onPressed: onToggleFavorite,
                        padding: EdgeInsets.zero, // Remove default padding
                        constraints:
                            const BoxConstraints(), // Remove default constraints
                      ),
                    ),
                  ),
                  // Custom Product Badge
                  if (product.isCustom)
                    Positioned(
                      top: kPaddingS,
                      left: kPaddingS,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: kPaddingS, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary, // Solid accent color
                          borderRadius:
                              BorderRadius.circular(kBorderRadius / 2),
                        ),
                        child: Text(
                          'Custom',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product Details
            Padding(
              padding: const EdgeInsets.all(kPaddingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                     const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.rate.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
