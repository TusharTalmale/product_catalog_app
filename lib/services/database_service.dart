import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:product_catalog_app/models/custom_product_model.dart';
import 'package:product_catalog_app/models/product_model.dart';
import 'package:logger/logger.dart';

class DatabaseService {
  static Database? _database;
  final Logger _logger = Logger();

  static const String _customProductsTable = 'custom_products';
  static const String _favoritesTable = 'favorites';

  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colDescription = 'description';
  static const String colPrice = 'price';
  static const String colCategory = 'category';
  static const String colImagePath = 'imagePath';
  static const String colCreatedAt = 'createdAt'; // Renamed from colDateAdded
  static const String colLastEditedAt = 'lastEditedAt'; // New column
  static const String colIsFavorite = 'isFavorite';

  static const String favColProductId = 'productId';
  static const String favColIsCustom = 'isCustom';
  static const String favColTitle = 'title';
  static const String favColImage = 'image';
  static const String favColPrice = 'price';
  static const String favColCreatedAt = 'createdAt'; // Renamed from favColDateAdded
  static const String favColLastEditedAt = 'lastEditedAt'; // New column
Future<void> init() async {
    await database; // Accessing the getter will ensure _initDB() is called
    _logger.i('DatabaseService public init() completed.');
  }
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'product_catalog.db');
    _logger.i('Initializing database at: $path');

    return await openDatabase(
      path,
      version: 4, // Increment database version
      onCreate: (db, version) async {
        _logger.i('Creating custom_products table...');
        await db.execute('''
          CREATE TABLE $_customProductsTable(
            $colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colTitle TEXT NOT NULL,
            $colDescription TEXT NOT NULL,
            $colPrice REAL NOT NULL,
            $colCategory TEXT NOT NULL,
            $colImagePath TEXT NOT NULL,
            $colCreatedAt TEXT NOT NULL,
            $colLastEditedAt TEXT NOT NULL,
            $colIsFavorite INTEGER NOT NULL DEFAULT 0
          )
        ''');
        _logger.i('custom_products table created.');

        _logger.i('Creating favorites table...');
        await db.execute('''
          CREATE TABLE $_favoritesTable(
            $favColProductId INTEGER NOT NULL,
            $favColIsCustom INTEGER NOT NULL,
            $favColTitle TEXT,
            $favColImage TEXT,
            $favColPrice REAL,
            $favColCreatedAt TEXT,
            $favColLastEditedAt TEXT, -- Added new column
            PRIMARY KEY ($favColProductId, $favColIsCustom)
          )
        ''');
        _logger.i('favorites table created.');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        _logger.i('Upgrading database from version $oldVersion to $newVersion');
        if (oldVersion < 2) {
          _logger.i('Adding new columns to favorites table for version 2 upgrade...');
          await db.execute('ALTER TABLE $_favoritesTable ADD COLUMN $favColTitle TEXT');
          await db.execute('ALTER TABLE $_favoritesTable ADD COLUMN $favColImage TEXT');
          await db.execute('ALTER TABLE $_favoritesTable ADD COLUMN $favColPrice REAL');
          _logger.i('Favorites table upgraded to version 2.');
        }
        if (oldVersion < 3) {
          _logger.i('Adding createdAt column to favorites table for version 3 upgrade...');
          // Renamed from favColDateAdded to favColCreatedAt during this upgrade
          await db.execute('ALTER TABLE $_favoritesTable ADD COLUMN $favColCreatedAt TEXT');
          _logger.i('Favorites table upgraded to version 3 (createdAt added).');
        }
        if (oldVersion < 4) {
          _logger.i('Adding lastEditedAt column to custom_products and favorites tables for version 4 upgrade...');
          await db.execute('ALTER TABLE $_customProductsTable ADD COLUMN $colLastEditedAt TEXT');
          await db.execute('ALTER TABLE $_favoritesTable ADD COLUMN $favColLastEditedAt TEXT');
          // For existing custom products, set lastEditedAt to createdAt
          await db.execute('UPDATE $_customProductsTable SET $colLastEditedAt = $colCreatedAt WHERE $colLastEditedAt IS NULL');
          // For existing favorite products, set lastEditedAt to createdAt
          await db.execute('UPDATE $_favoritesTable SET $favColLastEditedAt = $favColCreatedAt WHERE $favColLastEditedAt IS NULL');
          _logger.i('Tables upgraded to version 4 (lastEditedAt added).');
        }
      },
    );
  }

  /// --- Custom Product Operations ---

  Future<int> addCustomProduct(CustomProduct product) async {
    final db = await database;
    _logger.d('Adding custom product: ${product.title}');
    final id = await db.insert(
      _customProductsTable,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _logger.i('Custom product "${product.title}" added with ID: $id');
    return id;
  }

  Future<List<CustomProduct>> getCustomProducts() async {
    final db = await database;
    _logger.d('Fetching all custom products...');
    final List<Map<String, dynamic>> maps = await db.query(_customProductsTable);
    _logger.i('Found ${maps.length} custom products.');
    return List.generate(maps.length, (i) {
      return CustomProduct.fromMap(maps[i]);
    });
  }

  Future<int> updateCustomProduct(CustomProduct product) async {
    final db = await database;
    _logger.d('Updating custom product with ID: ${product.id}');
    final rowsAffected = await db.update(
      _customProductsTable,
      product.toMap(),
      where: '$colId = ?',
      whereArgs: [product.id],
    );
    _logger.i('Custom product ID ${product.id} updated. Rows affected: $rowsAffected');
    // If the product is currently a favorite, update its details in the favorites table too
    if (product.isFavorite) {
      await addFavoriteProduct(product.toProduct()); // Re-add to update details
    }
    return rowsAffected;
  }

  Future<int> deleteCustomProduct(int? id) async {
    if (id == null) {
      _logger.w('Attempted to delete custom product with null ID.');
      return 0;
    }
    final db = await database;
    _logger.d('Deleting custom product with ID: $id');
    final rowsAffected = await db.delete(
      _customProductsTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    _logger.i('Custom product ID $id deleted. Rows affected: $rowsAffected');
    await removeFavoriteProduct(id, true); // Also remove from favorites if it was a favorite custom product
    return rowsAffected;
  }

  /// --- Favorite Product Operations ---

  Future<void> addFavoriteProduct(Product product) async {
    final db = await database;
    _logger.d('Adding favorite: Product ID ${product.id}, isCustom: ${product.isCustom}');

    await db.insert(
      _favoritesTable,
      {
        favColProductId: product.id,
        favColIsCustom: product.isCustom ? 1 : 0,
        favColTitle: product.title,
        favColImage: product.image,
        favColPrice: product.price,
        favColCreatedAt: product.createdAt?.toIso8601String(), // Store createdAt if available
        favColLastEditedAt: product.lastEditedAt?.toIso8601String(), // Store lastEditedAt if available
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Use replace to update existing favorite details
    );
    _logger.i('Product ID ${product.id} added/updated in favorites table.');
  }

  Future<void> removeFavoriteProduct(int productId, bool isCustom) async {
    final db = await database;
    _logger.d('Removing favorite: Product ID $productId, isCustom: $isCustom');

    await db.delete(
      _favoritesTable,
      where: '$favColProductId = ? AND $favColIsCustom = ?',
      whereArgs: [productId, isCustom ? 1 : 0],
    );
    _logger.i('Product ID $productId removed from favorites table.');

    if (isCustom) {
      await db.update(
        _customProductsTable,
        {colIsFavorite: 0},
        where: '$colId = ?',
        whereArgs: [productId],
      );
      _logger.i('Custom product ID $productId unmarked as favorite in custom_products table.');
    }
  }

  Future<Set<int>> getFavoriteProductIds() async {
    final db = await database;
    _logger.d('Fetching all favorite entries to update product states...');
    final List<Map<String, dynamic>> maps = await db.query(
      _favoritesTable,
      columns: [favColProductId, favColIsCustom],
    );

    final Set<int> favoriteApiIds = {};

    for (var map in maps) {
      final bool isCustom = (map[favColIsCustom] as int) == 1;
      if (!isCustom) {
        favoriteApiIds.add(map[favColProductId] as int);
      }
    }
    _logger.i('Found ${favoriteApiIds.length} favorite API IDs.');
    return favoriteApiIds;
  }

  Future<List<Product>> getAllFavoriteProducts() async {
    final db = await database;
    _logger.d('Fetching all favorite products for display...');
    final List<Map<String, dynamic>> maps = await db.query(_favoritesTable);

    List<Product> favorites = [];
    for (var map in maps) {
      final int productId = map[favColProductId] as int;
      final bool isCustom = (map[favColIsCustom] as int) == 1;
      final String title = map[favColTitle] as String;
      final String image = map[favColImage] as String;
      final double price = map[favColPrice] as double;
      final String? createdAtString = map[favColCreatedAt] as String?;
      final DateTime? createdAt = createdAtString != null ? DateTime.tryParse(createdAtString) : null;
      final String? lastEditedAtString = map[favColLastEditedAt] as String?;
      final DateTime? lastEditedAt = lastEditedAtString != null ? DateTime.tryParse(lastEditedAtString) : null;

      favorites.add(
        Product(
          id: productId,
          title: title,
          price: price,
          description: '',
          category: '',
          image: image,
          rating: Rating(rate: 0.0, count: 0),
          isFavorite: true,
          isCustom: isCustom,
          createdAt: createdAt,
          lastEditedAt: lastEditedAt,
        ),
      );
    }
    _logger.i('Found ${favorites.length} total favorite products for display.');
    return favorites;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    _logger.i('Database closed.');
  }
}
