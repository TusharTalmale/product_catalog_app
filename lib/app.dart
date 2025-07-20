import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:product_catalog_app/models/product_model.dart';
import 'package:product_catalog_app/screens/add_product.dart';
import 'package:product_catalog_app/screens/my_custom_product_screen.dart';
import 'package:product_catalog_app/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:product_catalog_app/providers/product_provider.dart';
import 'package:product_catalog_app/screens/home_screen.dart';
import 'package:product_catalog_app/screens/detail_screen.dart';
import 'package:product_catalog_app/utils/theme.dart'; // Import theme definitions

class ProductCatalogApp extends StatelessWidget {
  const ProductCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return MaterialApp(
          title: 'Product Catalog',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: productProvider.themeMode,
          debugShowCheckedModeBanner: false,
          // useInheritedMediaQuery: true,
          // locale: DevicePreview.locale(context),
          // builder: DevicePreview.appBuilder,
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/': (context) => const HomeScreen(),
            '/favorites_tab': (context) => const HomeScreen(initialTabIndex: 1),
            '/add_product_tab': (context) => const AddProductScreen(),

            // Other screens
            '/add_product': (context) => const AddProductScreen(),
            '/my_custom': (context) => const MyCustomProductsScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final product = settings.arguments as Product?;
              if (product != null) {
                return MaterialPageRoute(
                  builder: (context) => DetailScreen(product: product),
                );
              }
            }
            return null;
          },
        );
      },
    );
  }
}
