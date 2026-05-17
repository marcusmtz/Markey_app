import 'package:flutter/foundation.dart';
import '../../../../core/utils/result.dart';
import '../../domain/category.dart' as domain;
import '../../domain/category_repository.dart';

/// Provider for managing categories
class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository;

  CategoryProvider({required CategoryRepository repository})
    : _repository = repository {
    loadCategories();
  }

  List<domain.Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<domain.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all categories
  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getAllCategories();
      if (result.isSuccess) {
        _categories = result.valueOrNull ?? [];
      } else {
        _errorMessage =
            result.errorOrNull?.message ?? 'Error al cargar categorías';
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar categorías: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new category
  Future<bool> createCategory(String name, String colorHex) async {
    try {
      final category = domain.Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        colorHex: colorHex,
        isPredefined: false,
      );

      final result = await _repository.createCategory(category);
      if (result.isSuccess) {
        await loadCategories();
        return true;
      } else {
        _errorMessage =
            result.errorOrNull?.message ?? 'Error al crear categoría';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al crear categoría: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Update an existing category
  Future<bool> updateCategory(String id, String name, String colorHex) async {
    try {
      // Find the existing category
      final existing = _categories.firstWhere((c) => c.id == id);

      // Delete the old one
      final deleteResult = await _repository.deleteCategory(id);
      if (deleteResult.isFailure) {
        _errorMessage =
            deleteResult.errorOrNull?.message ??
            'Error al actualizar categoría';
        notifyListeners();
        return false;
      }

      // Create the updated one
      final updated = existing.copyWith(name: name, colorHex: colorHex);
      final createResult = await _repository.createCategory(updated);

      if (createResult.isSuccess) {
        await loadCategories();
        return true;
      } else {
        _errorMessage =
            createResult.errorOrNull?.message ??
            'Error al actualizar categoría';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al actualizar categoría: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Delete a category
  Future<bool> deleteCategory(String id) async {
    try {
      final result = await _repository.deleteCategory(id);
      if (result.isSuccess) {
        await loadCategories();
        return true;
      } else {
        _errorMessage =
            result.errorOrNull?.message ?? 'Error al eliminar categoría';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al eliminar categoría: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Get category by ID
  domain.Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get entries count for all categories
  Future<Map<String, int>> getEntriesCount() async {
    final result = await _repository.getEntriesCountByCategory();
    if (result.isSuccess) {
      return result.valueOrNull ?? {};
    }
    return {};
  }
}
