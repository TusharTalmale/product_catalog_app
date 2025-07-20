import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:product_catalog_app/app.dart';
import 'package:product_catalog_app/providers/product_provider.dart';
import 'package:product_catalog_app/services/database_service.dart';
import 'package:product_catalog_app/services/api_service.dart';
import 'package:product_catalog_app/services/image_helper.dart';
import 'package:logger/logger.dart';
import 'package:device_preview/device_preview.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // ✅ import this
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Logger logger = Logger();
  logger.i('Application starting...');

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
    logger.i('sqflite_common_ffi_web initialized for web.');
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    logger.i('sqflite_common_ffi initialized for desktop.');
  } else {
    logger.i('Running on mobile, no need to configure sqflite manually.');
  }

  // Database setup
  final databaseService = DatabaseService();
  try {
    await databaseService.init();
    logger.i('DatabaseService initialized successfully.');
  } catch (e, stack) {
    logger.e('Failed to initialize DatabaseService: $e', error: e, stackTrace: stack);
  }

  final apiService = ApiService.create();
  final imageHelper = ImageHelper();

  runApp(
    // DevicePreview(
    //   enabled: true,
    //   builder: (context) => 
      MultiProvider(
        providers: [
          Provider.value(value: databaseService),
          Provider.value(value: apiService),
          Provider.value(value: imageHelper),
          ChangeNotifierProvider(
            create: (context) => ProductProvider(
              apiService: context.read<ApiService>(),
              databaseService: context.read<DatabaseService>(),
              imageHelper: context.read<ImageHelper>(),
            )..loadInitialData(),
          ),
        ],
        child: const ProductCatalogApp(),
      ),
    // ),
  );
}
