import 'package:product_catalog_app/models/product_model.dart';

class CustomProduct {
  final int? id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String imagePath;
  
  final DateTime createdAt; // Renamed from dateAdded
  final DateTime lastEditedAt; // New field

  bool isFavorite;

  final bool isCustom = true;

  CustomProduct({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.imagePath,
     required this.createdAt,
    required this.lastEditedAt, 
    this.isFavorite = false,
    
  });

  factory CustomProduct.fromMap(Map<String, dynamic> map) {
    return CustomProduct(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      price: map['price'] as double,
      category: map['category'] as String,
      imagePath: map['imagePath'] as String,
       createdAt: DateTime.parse(map['createdAt'] as String), // Updated column name
      lastEditedAt: DateTime.parse(map['lastEditedAt'] as String), // New column
      isFavorite: (map['isFavorite'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'imagePath': imagePath,
       'createdAt': createdAt.toIso8601String(),
      'lastEditedAt': lastEditedAt.toIso8601String(), // Store as ISO string
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  CustomProduct copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    String? category,
    String? imagePath,
    DateTime? dateAdded,
      DateTime? createdAt,
    DateTime? lastEditedAt,
    bool? isFavorite,
  }) {
    return CustomProduct(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
       createdAt: createdAt ?? this.createdAt,
      lastEditedAt: lastEditedAt ?? this.lastEditedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Product toProduct() {
    return Product(
      id: id ?? -1,
      title: title,
      price: price,
      description: description,
      category: category,
      image: imagePath,
      rating: Rating(rate: 0.0, count: 0),
      isFavorite: isFavorite,
      isCustom: true,
       createdAt: createdAt,
      lastEditedAt: lastEditedAt,
    );
  }

  @override
  String toString() {
    return 'CustomProduct(id: $id, title: $title, price: $price, category: $category, imagePath: $imagePath, isFavorite: $isFavorite,  createdAt: $createdAt, lastEditedAt: $lastEditedAt)';
  }
}
