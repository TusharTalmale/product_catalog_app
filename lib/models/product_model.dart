import 'package:json_annotation/json_annotation.dart';
part 'product_model.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final Rating rating;

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool isFavorite;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool isCustom;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime? createdAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime? lastEditedAt;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
    this.isFavorite = false,
    this.isCustom = false,
    this.createdAt, 
    this.lastEditedAt,

  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? description,
    String? category,
    String? image,
    
    Rating? rating,
    bool? isFavorite,
    bool? isCustom,
     DateTime? createdAt,
    DateTime? lastEditedAt,

  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      isCustom: isCustom ?? this.isCustom,
       createdAt: createdAt ?? this.createdAt,
      lastEditedAt: lastEditedAt ?? this.lastEditedAt,

    );
  }

  @override
  String toString() {
    return 'Product(id: $id, title: $title, price: $price, category: $category, isFavorite: $isFavorite, isCustom: $isCustom, createdAt: $createdAt, lastEditedAt: $lastEditedAt)';
  }
}

@JsonSerializable()
class Rating {
  final double rate;
  final int count;

  Rating({
    required this.rate,
    required this.count,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => _$RatingFromJson(json);
  Map<String, dynamic> toJson() => _$RatingToJson(this);

  @override
  String toString() {
    return 'Rating(rate: $rate, count: $count)';
  }
}
