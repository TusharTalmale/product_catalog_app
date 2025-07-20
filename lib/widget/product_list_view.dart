import 'package:flutter/material.dart';
import 'package:product_catalog_app/widget/product_list_item.dart';
import 'package:provider/provider.dart';
import 'package:product_catalog_app/providers/product_provider.dart';
import 'package:product_catalog_app/utils/constants.dart';

class ProductListView extends StatelessWidget {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return ListView.builder(
      padding: const EdgeInsets.all(kPaddingS),
      itemCount: productProvider.products.length,
      itemBuilder: (context, index) {
        final product = productProvider.products[index];
        return ProductListItem(
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
  }
}
