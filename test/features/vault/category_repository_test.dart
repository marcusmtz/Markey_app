import 'package:flutter_test/flutter_test.dart';
import 'package:markey_app/core/services/encryption_service_impl.dart';
import 'package:markey_app/core/utils/result.dart';
import 'package:markey_app/features/vault/data/category_repository_impl.dart';
import 'package:markey_app/features/vault/data/vault_repository_impl.dart';
import 'package:markey_app/features/vault/domain/category.dart';
import 'package:markey_app/features/vault/domain/category_repository.dart';
import 'package:markey_app/features/vault/domain/entry.dart';
import 'package:markey_app/features/vault/domain/vault_repository.dart';
import '../../features/auth/mock_secure_storage.dart';

void main() {
  late CategoryRepository categoryRepository;
  late VaultRepository vaultRepository;
  late MockSecureStorage storage;
  const testMasterKey = 'TestMasterPassword123!';

  setUp(() {
    storage = MockSecureStorage();
    final encryptionService = EncryptionServiceImpl();
    vaultRepository = VaultRepositoryImpl(
      encryptionService: encryptionService,
      storageService: storage,
      masterKey: testMasterKey,
    );
    categoryRepository = CategoryRepositoryImpl(
      encryptionService: encryptionService,
      storageService: storage,
      vaultRepository: vaultRepository,
      masterKey: testMasterKey,
    );
  });

  // Helper functions to check Result types
  bool isSuccess<T>(Result<T> result) => result is Success<T>;
  bool isFailure<T>(Result<T> result) => result is Failure<T>;
  T? getValue<T>(Result<T> result) =>
      result is Success<T> ? result.value : null;

  group('CategoryRepository - Basic Operations', () {
    test('should load predefined categories', () async {
      final result = await categoryRepository.loadPredefinedCategories();

      expect(isSuccess(result), isTrue);
    });

    test('should get all predefined categories', () async {
      final result = await categoryRepository.getAllCategories();

      expect(isSuccess(result), isTrue);
      final categories = getValue(result)!;

      // Should have 7 predefined categories (including "Sin categoría")
      final predefined = categories.where((c) => c.isPredefined).toList();
      expect(predefined.length, equals(7));

      // Check that "Sin categoría" exists
      expect(predefined.any((c) => c.id == 'sin-categoria'), isTrue);
    });

    test('should create custom category', () async {
      final customCategory = Category(
        id: 'custom-1',
        name: 'Gaming',
        colorHex: '#E91E63',
        isPredefined: false,
      );

      final result = await categoryRepository.createCategory(customCategory);

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.name, equals('Gaming'));
    });

    test('should fail to create category with duplicate name', () async {
      final customCategory = Category(
        id: 'custom-1',
        name: 'Gaming',
        colorHex: '#E91E63',
        isPredefined: false,
      );

      // Create first category
      await categoryRepository.createCategory(customCategory);

      // Try to create duplicate
      final duplicateCategory = Category(
        id: 'custom-2',
        name: 'Gaming', // Same name
        colorHex: '#000000',
        isPredefined: false,
      );

      final result = await categoryRepository.createCategory(duplicateCategory);

      expect(isFailure(result), isTrue);
    });

    test('should fail to create predefined category', () async {
      final predefinedCategory = Category(
        id: 'test',
        name: 'Test',
        colorHex: '#000000',
        isPredefined: true, // Marked as predefined
      );

      final result = await categoryRepository.createCategory(
        predefinedCategory,
      );

      expect(isFailure(result), isTrue);
    });

    test('should get all categories including custom', () async {
      final customCategory = Category(
        id: 'custom-1',
        name: 'Gaming',
        colorHex: '#E91E63',
        isPredefined: false,
      );

      await categoryRepository.createCategory(customCategory);

      final result = await categoryRepository.getAllCategories();

      expect(isSuccess(result), isTrue);
      final categories = getValue(result)!;

      // Should have 7 predefined + 1 custom
      expect(categories.length, equals(8));
      expect(
        categories.any((c) => c.name == 'Gaming' && !c.isPredefined),
        isTrue,
      );
    });
  });

  group('CategoryRepository - Deletion', () {
    test('should delete custom category', () async {
      final customCategory = Category(
        id: 'custom-1',
        name: 'Gaming',
        colorHex: '#E91E63',
        isPredefined: false,
      );

      await categoryRepository.createCategory(customCategory);

      final deleteResult = await categoryRepository.deleteCategory('custom-1');

      expect(isSuccess(deleteResult), isTrue);

      // Verify it's deleted
      final allResult = await categoryRepository.getAllCategories();
      final categories = getValue(allResult)!;
      expect(categories.any((c) => c.id == 'custom-1'), isFalse);
    });

    test('should fail to delete predefined category', () async {
      final result = await categoryRepository.deleteCategory('trabajo');

      expect(isFailure(result), isTrue);
    });

    test('should fail to delete non-existent category', () async {
      final result = await categoryRepository.deleteCategory('non-existent');

      expect(isFailure(result), isTrue);
    });

    test(
      'should reassign entries to "Sin categoría" when deleting category',
      () async {
        // Create custom category
        final customCategory = Category(
          id: 'custom-1',
          name: 'Gaming',
          colorHex: '#E91E63',
          isPredefined: false,
        );
        await categoryRepository.createCategory(customCategory);

        // Create entry with custom category
        final entry = Entry(
          id: '1',
          title: 'Steam',
          username: 'gamer',
          password: 'Pass123!',
          categories: ['custom-1'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await vaultRepository.createEntry(entry);

        // Delete the custom category
        await categoryRepository.deleteCategory('custom-1');

        // Verify entry was reassigned to "Sin categoría"
        final entryResult = await vaultRepository.getEntryById('1');
        final updatedEntry = getValue(entryResult);
        expect(updatedEntry!.categories.contains('sin-categoria'), isTrue);
        expect(updatedEntry.categories.contains('custom-1'), isFalse);
      },
    );
  });

  group('CategoryRepository - Entry Count', () {
    test(
      'should return zero count for all categories when no entries',
      () async {
        final result = await categoryRepository.getEntriesCountByCategory();

        expect(isSuccess(result), isTrue);
        final countMap = getValue(result)!;

        // All predefined categories should have count 0
        expect(countMap['trabajo'], equals(0));
        expect(countMap['personal'], equals(0));
        expect(countMap['bancario'], equals(0));
      },
    );

    test('should count entries correctly by category', () async {
      // Create entries with different categories
      final entry1 = Entry(
        id: '1',
        title: 'Gmail',
        username: 'user',
        password: 'Pass123!',
        categories: ['personal', 'correo'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final entry2 = Entry(
        id: '2',
        title: 'Bank',
        username: 'user',
        password: 'Pass123!',
        categories: ['bancario'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final entry3 = Entry(
        id: '3',
        title: 'Work Email',
        username: 'user',
        password: 'Pass123!',
        categories: ['trabajo', 'correo'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await vaultRepository.createEntry(entry1);
      await vaultRepository.createEntry(entry2);
      await vaultRepository.createEntry(entry3);

      final result = await categoryRepository.getEntriesCountByCategory();

      expect(isSuccess(result), isTrue);
      final countMap = getValue(result)!;

      expect(countMap['personal'], equals(1));
      expect(countMap['bancario'], equals(1));
      expect(countMap['trabajo'], equals(1));
      expect(countMap['correo'], equals(2)); // Two entries have 'correo'
    });

    test('should count custom category entries', () async {
      // Create custom category
      final customCategory = Category(
        id: 'custom-1',
        name: 'Gaming',
        colorHex: '#E91E63',
        isPredefined: false,
      );
      await categoryRepository.createCategory(customCategory);

      // Create entry with custom category
      final entry = Entry(
        id: '1',
        title: 'Steam',
        username: 'gamer',
        password: 'Pass123!',
        categories: ['custom-1'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await vaultRepository.createEntry(entry);

      final result = await categoryRepository.getEntriesCountByCategory();

      expect(isSuccess(result), isTrue);
      final countMap = getValue(result)!;
      expect(countMap['custom-1'], equals(1));
    });
  });
}
