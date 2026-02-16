import '../domain/category.dart';

/// Data model for Category with JSON serialization
class CategoryModel {
  final String id;
  final String name;
  final String colorHex;
  final bool isPredefined;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.isPredefined,
  });

  /// Converts this model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorHex': colorHex,
      'isPredefined': isPredefined,
    };
  }

  /// Creates a model from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      colorHex: json['colorHex'] as String,
      isPredefined: json['isPredefined'] as bool,
    );
  }

  /// Converts domain Category to CategoryModel
  factory CategoryModel.fromDomain(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      colorHex: category.colorHex,
      isPredefined: category.isPredefined,
    );
  }

  /// Converts this model to domain Category
  Category toDomain() {
    return Category(
      id: id,
      name: name,
      colorHex: colorHex,
      isPredefined: isPredefined,
    );
  }
}
