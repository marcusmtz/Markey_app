import 'dart:convert';
import '../../../core/errors/failures.dart';
import '../../../core/services/encryption_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/utils/result.dart';
import '../domain/category.dart';
import '../domain/category_repository.dart';
import '../domain/vault_repository.dart';
import 'category_model.dart';

/// Implementation of CategoryRepository
/// Manages encrypted storage of custom categories
class CategoryRepositoryImpl implements CategoryRepository {
  final EncryptionService _encryptionService;
  final SecureStorageService _storageService;
  final VaultRepository _vaultRepository;
  final String _masterKey;

  static const String _categoriesKey = 'custom_categories';
  static const String _uncategorizedId = 'sin-categoria';

  CategoryRepositoryImpl({
    required EncryptionService encryptionService,
    required SecureStorageService storageService,
    required VaultRepository vaultRepository,
    required String masterKey,
  }) : _encryptionService = encryptionService,
       _storageService = storageService,
       _vaultRepository = vaultRepository,
       _masterKey = masterKey;

  @override
  Future<Result<List<Category>>> getAllCategories() async {
    try {
      // Get predefined categories
      final predefined = Category.getPredefinedCategories();

      // Get custom categories
      final customResult = await _getCustomCategories();
      if (customResult.isFailure) {
        return Failure(customResult.errorOrNull!);
      }

      final custom = customResult.valueOrNull!;

      // Combine and return
      return Success([...predefined, ...custom]);
    } catch (e) {
      return Failure(
        StorageError('Failed to retrieve categories', e.toString()),
      );
    }
  }

  @override
  Future<Result<Category>> createCategory(Category category) async {
    try {
      // Validate that it's not a predefined category
      if (category.isPredefined) {
        return Failure(
          ValidationError('Category creation failed', {
            'isPredefined': 'Cannot create predefined categories',
          }),
        );
      }

      // Get all existing categories
      final allCategoriesResult = await getAllCategories();
      if (allCategoriesResult.isFailure) {
        return Failure(allCategoriesResult.errorOrNull!);
      }

      final allCategories = allCategoriesResult.valueOrNull!;

      // Check if category with same name already exists (case-insensitive)
      final nameLower = category.name.toLowerCase();
      if (allCategories.any((c) => c.name.toLowerCase() == nameLower)) {
        return Failure(
          ValidationError('Category creation failed', {
            'name': 'Category with this name already exists',
          }),
        );
      }

      // Get custom categories
      final customResult = await _getCustomCategories();
      if (customResult.isFailure) {
        return Failure(customResult.errorOrNull!);
      }

      final customCategories = List<Category>.from(customResult.valueOrNull!);

      // Add new category
      customCategories.add(category);

      // Save custom categories
      final saveResult = await _saveCustomCategories(customCategories);
      if (saveResult.isFailure) {
        return Failure(saveResult.errorOrNull!);
      }

      return Success(category);
    } catch (e) {
      return Failure(StorageError('Failed to create category', e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteCategory(String id) async {
    try {
      // Get custom categories
      final customResult = await _getCustomCategories();
      if (customResult.isFailure) {
        return Failure(customResult.errorOrNull!);
      }

      final customCategories = List<Category>.from(customResult.valueOrNull!);

      // Find the category to delete
      final categoryToDelete = customCategories.where((c) => c.id == id);
      if (categoryToDelete.isEmpty) {
        // Check if it's a predefined category
        final predefined = Category.getPredefinedCategories();
        if (predefined.any((c) => c.id == id)) {
          return Failure(
            ValidationError('Category deletion failed', {
              'id': 'Cannot delete predefined categories',
            }),
          );
        }

        return Failure(
          ValidationError('Category deletion failed', {
            'id': 'Category not found',
          }),
        );
      }

      // Remove the category
      customCategories.removeWhere((c) => c.id == id);

      // Reassign entries from this category to "Sin categoría"
      final reassignResult = await _reassignEntriesToUncategorized(id);
      if (reassignResult.isFailure) {
        return Failure(reassignResult.errorOrNull!);
      }

      // Save custom categories
      final saveResult = await _saveCustomCategories(customCategories);
      if (saveResult.isFailure) {
        return Failure(saveResult.errorOrNull!);
      }

      return const Success(null);
    } catch (e) {
      return Failure(StorageError('Failed to delete category', e.toString()));
    }
  }

  @override
  Future<Result<Map<String, int>>> getEntriesCountByCategory() async {
    try {
      // Get all entries
      final entriesResult = await _vaultRepository.getAllEntries();
      if (entriesResult.isFailure) {
        return Failure(entriesResult.errorOrNull!);
      }

      final entries = entriesResult.valueOrNull!;

      // Get all categories
      final categoriesResult = await getAllCategories();
      if (categoriesResult.isFailure) {
        return Failure(categoriesResult.errorOrNull!);
      }

      final categories = categoriesResult.valueOrNull!;

      // Initialize count map with all categories set to 0
      final countMap = <String, int>{};
      for (final category in categories) {
        countMap[category.id] = 0;
      }

      // Count entries for each category
      for (final entry in entries) {
        for (final categoryId in entry.categories) {
          if (countMap.containsKey(categoryId)) {
            countMap[categoryId] = countMap[categoryId]! + 1;
          }
        }
      }

      return Success(countMap);
    } catch (e) {
      return Failure(
        StorageError('Failed to count entries by category', e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> loadPredefinedCategories() async {
    // Predefined categories are loaded from Category.getPredefinedCategories()
    // No storage operation needed as they are hardcoded
    return const Success(null);
  }

  /// Retrieves custom categories from encrypted storage
  Future<Result<List<Category>>> _getCustomCategories() async {
    try {
      // Read encrypted categories from storage
      final readResult = await _storageService.read(_categoriesKey);
      if (readResult.isFailure) {
        return Failure(readResult.errorOrNull!);
      }

      final encryptedData = readResult.valueOrNull;
      if (encryptedData == null || encryptedData.isEmpty) {
        return const Success([]);
      }

      // Decrypt the categories data
      final decryptResult = await _encryptionService.decrypt(
        encryptedData,
        _masterKey,
      );
      if (decryptResult.isFailure) {
        return Failure(decryptResult.errorOrNull!);
      }

      // Parse JSON array
      final jsonData = jsonDecode(decryptResult.valueOrNull!);
      if (jsonData is! List) {
        return Failure(
          StorageError('Invalid categories data format', 'Expected JSON array'),
        );
      }

      // Convert to Category objects
      final categories = <Category>[];
      for (final item in jsonData) {
        if (item is! Map<String, dynamic>) continue;

        try {
          final model = CategoryModel.fromJson(item);
          categories.add(model.toDomain());
        } catch (e) {
          // Skip invalid categories but continue processing
          continue;
        }
      }

      return Success(categories);
    } catch (e) {
      return Failure(
        StorageError('Failed to retrieve custom categories', e.toString()),
      );
    }
  }

  /// Saves custom categories to encrypted storage
  Future<Result<void>> _saveCustomCategories(List<Category> categories) async {
    try {
      // Convert categories to models
      final models = categories
          .map((c) => CategoryModel.fromDomain(c))
          .map((m) => m.toJson())
          .toList();

      // Convert to JSON string
      final jsonString = jsonEncode(models);

      // Encrypt the entire JSON
      final encryptResult = await _encryptionService.encrypt(
        jsonString,
        _masterKey,
      );
      if (encryptResult.isFailure) {
        return Failure(encryptResult.errorOrNull!);
      }

      // Save to storage
      final writeResult = await _storageService.write(
        _categoriesKey,
        encryptResult.valueOrNull!,
      );
      if (writeResult.isFailure) {
        return Failure(writeResult.errorOrNull!);
      }

      return const Success(null);
    } catch (e) {
      return Failure(
        StorageError('Failed to save custom categories', e.toString()),
      );
    }
  }

  /// Reassigns all entries from a deleted category to "Sin categoría"
  Future<Result<void>> _reassignEntriesToUncategorized(
    String deletedCategoryId,
  ) async {
    try {
      // Get all entries
      final entriesResult = await _vaultRepository.getAllEntries();
      if (entriesResult.isFailure) {
        return Failure(entriesResult.errorOrNull!);
      }

      final entries = entriesResult.valueOrNull!;

      // Find entries that have the deleted category
      for (final entry in entries) {
        if (entry.categories.contains(deletedCategoryId)) {
          // Remove the deleted category and add "Sin categoría" if not present
          final updatedCategories = List<String>.from(entry.categories);
          updatedCategories.remove(deletedCategoryId);

          if (updatedCategories.isEmpty ||
              !updatedCategories.contains(_uncategorizedId)) {
            updatedCategories.add(_uncategorizedId);
          }

          // Update the entry
          final updatedEntry = entry.copyWith(
            categories: updatedCategories,
            updatedAt: DateTime.now(),
          );

          final updateResult = await _vaultRepository.updateEntry(updatedEntry);
          if (updateResult.isFailure) {
            return Failure(updateResult.errorOrNull!);
          }
        }
      }

      return const Success(null);
    } catch (e) {
      return Failure(StorageError('Failed to reassign entries', e.toString()));
    }
  }
}
