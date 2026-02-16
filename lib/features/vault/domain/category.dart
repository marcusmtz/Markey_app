/// Domain entity representing a category for organizing entries
class Category {
  final String id;
  final String name;
  final String colorHex;
  final bool isPredefined;

  const Category({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.isPredefined,
  });

  /// Returns the list of predefined categories
  /// Only "Sin categoría" is predefined, users can create custom categories
  static List<Category> getPredefinedCategories() {
    return [
      const Category(
        id: 'sin-categoria',
        name: 'Sin categoría',
        colorHex: '#9E9E9E',
        isPredefined: true,
      ),
    ];
  }

  /// Creates a copy of this category with the given fields replaced
  Category copyWith({
    String? id,
    String? name,
    String? colorHex,
    bool? isPredefined,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      isPredefined: isPredefined ?? this.isPredefined,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.colorHex == colorHex &&
        other.isPredefined == isPredefined;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, colorHex, isPredefined);
  }
}
