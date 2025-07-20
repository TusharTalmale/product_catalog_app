import 'package:flutter/material.dart';
import 'package:product_catalog_app/widget/product_card.dart';
import 'package:provider/provider.dart';
import 'package:product_catalog_app/providers/product_provider.dart';
import 'package:product_catalog_app/utils/constants.dart';

class ProductGridView extends StatelessWidget {
  const ProductGridView({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    final int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(kPaddingS),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: kPaddingS,
        mainAxisSpacing: kPaddingS,
        childAspectRatio: kProductCardAspectRatio,
      ),
      itemCount: productProvider.products.length,
      itemBuilder: (context, index) {
        final product = productProvider.products[index];
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
  }
}
