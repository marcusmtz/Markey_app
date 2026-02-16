import '../../../core/utils/result.dart';
import 'category.dart';

/// Abstract repository interface for category operations
/// Manages predefined and custom categories
abstract class CategoryRepository {
  /// Retrieves all categories (predefined + custom)
  Future<Result<List<Category>>> getAllCategories();

  /// Creates a new custom category
  /// Returns error if category with same name already exists
  Future<Result<Category>> createCategory(Category category);

  /// Deletes a custom category by ID
  /// Predefined categories cannot be deleted
  /// Entries assigned to this category will be reassigned to "Sin categoría"
  Future<Result<void>> deleteCategory(String id);

  /// Gets the count of entries for each category
  /// Returns a map of category ID to entry count
  Future<Result<Map<String, int>>> getEntriesCountByCategory();

  /// Loads predefined categories at initialization
  Future<Result<void>> loadPredefinedCategories();
}
