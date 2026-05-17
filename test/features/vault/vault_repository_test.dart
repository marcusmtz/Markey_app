import 'package:flutter_test/flutter_test.dart';
import 'package:markey_app/core/services/encryption_service_impl.dart';
import 'package:markey_app/core/utils/result.dart';
import 'package:markey_app/features/vault/data/vault_repository_impl.dart';
import 'package:markey_app/features/vault/domain/entry.dart';
import 'package:markey_app/features/vault/domain/vault_repository.dart';
import '../../features/auth/mock_secure_storage.dart';

void main() {
  late VaultRepository repository;
  late MockSecureStorage storage;
  const testMasterKey = 'TestMasterPassword123!';

  setUp(() {
    storage = MockSecureStorage();
    final encryptionService = EncryptionServiceImpl();
    repository = VaultRepositoryImpl(
      encryptionService: encryptionService,
      storageService: storage,
      masterKey: testMasterKey,
    );
  });

  // Helper functions to check Result types
  bool isSuccess<T>(Result<T> result) => result is Success<T>;
  bool isFailure<T>(Result<T> result) => result is Failure<T>;
  T? getValue<T>(Result<T> result) =>
      result is Success<T> ? result.value : null;

  group('VaultRepository - CRUD Operations', () {
    test('should create entry with required fields', () async {
      final entry = Entry(
        id: '1',
        title: 'Test Entry',
        username: 'testuser',
        password: 'TestPass123!',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repository.createEntry(entry);

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.id, equals('1'));
      expect(getValue(result)?.title, equals('Test Entry'));
    });

    test('should fail to create entry without title', () async {
      final entry = Entry(
        id: '1',
        title: '',
        username: 'testuser',
        password: 'TestPass123!',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repository.createEntry(entry);

      expect(isFailure(result), isTrue);
    });

    test('should fail to create entry without password', () async {
      final entry = Entry(
        id: '1',
        title: 'Test Entry',
        username: 'testuser',
        password: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repository.createEntry(entry);

      expect(isFailure(result), isTrue);
    });

    test('should create entry with all fields', () async {
      final entry = Entry(
        id: '1',
        title: 'Gmail',
        username: 'user@example.com',
        password: 'SecurePass123!',
        url: 'https://gmail.com',
        notes: 'Personal email',
        categories: ['Personal', 'Email'],
        isFavorite: true,
        totpSecret: 'JBSWY3DPEHPK3PXP',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repository.createEntry(entry);

      expect(isSuccess(result), isTrue);
      final created = getValue(result)!;
      expect(created.title, equals('Gmail'));
      expect(created.username, equals('user@example.com'));
      expect(created.url, equals('https://gmail.com'));
      expect(created.notes, equals('Personal email'));
      expect(created.categories, equals(['Personal', 'Email']));
      expect(created.isFavorite, isTrue);
      expect(created.totpSecret, equals('JBSWY3DPEHPK3PXP'));
    });

    test('should retrieve all entries', () async {
      final entry1 = Entry(
        id: '1',
        title: 'Entry 1',
        username: 'user1',
        password: 'pass1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final entry2 = Entry(
        id: '2',
        title: 'Entry 2',
        username: 'user2',
        password: 'pass2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createEntry(entry1);
      await repository.createEntry(entry2);

      final result = await repository.getAllEntries();

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.length, equals(2));
    });

    test('should retrieve entry by ID', () async {
      final entry = Entry(
        id: 'test-id',
        title: 'Test Entry',
        username: 'testuser',
        password: 'TestPass123!',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createEntry(entry);

      final result = await repository.getEntryById('test-id');

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.id, equals('test-id'));
      expect(getValue(result)?.title, equals('Test Entry'));
    });

    test('should return null for non-existent entry ID', () async {
      final result = await repository.getEntryById('non-existent');

      expect(isSuccess(result), isTrue);
      expect(getValue(result), isNull);
    });

    test('should update existing entry', () async {
      final entry = Entry(
        id: '1',
        title: 'Original Title',
        username: 'user',
        password: 'pass',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createEntry(entry);

      final updated = entry.copyWith(
        title: 'Updated Title',
        updatedAt: DateTime.now(),
      );

      final result = await repository.updateEntry(updated);

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.title, equals('Updated Title'));

      final retrieved = await repository.getEntryById('1');
      expect(getValue(retrieved)?.title, equals('Updated Title'));
    });

    test('should add to password history when password changes', () async {
      final entry = Entry(
        id: '1',
        title: 'Test',
        username: 'user',
        password: 'OldPassword',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createEntry(entry);

      final updated = entry.copyWith(
        password: 'NewPassword',
        updatedAt: DateTime.now(),
      );

      final result = await repository.updateEntry(updated);

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.password, equals('NewPassword'));
      expect(getValue(result)?.passwordHistory.length, equals(1));
      expect(
        getValue(result)?.passwordHistory.first.password,
        equals('OldPassword'),
      );
    });

    test(
      'should not add to password history when password unchanged',
      () async {
        final entry = Entry(
          id: '1',
          title: 'Test',
          username: 'user',
          password: 'SamePassword',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.createEntry(entry);

        final updated = entry.copyWith(
          title: 'Updated Title',
          updatedAt: DateTime.now(),
        );

        final result = await repository.updateEntry(updated);

        expect(isSuccess(result), isTrue);
        expect(getValue(result)?.passwordHistory.length, equals(0));
      },
    );

    test('should fail to update non-existent entry', () async {
      final entry = Entry(
        id: 'non-existent',
        title: 'Test',
        username: 'user',
        password: 'pass',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repository.updateEntry(entry);

      expect(isFailure(result), isTrue);
    });

    test('should delete existing entry', () async {
      final entry = Entry(
        id: '1',
        title: 'Test',
        username: 'user',
        password: 'pass',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createEntry(entry);

      final deleteResult = await repository.deleteEntry('1');
      expect(isSuccess(deleteResult), isTrue);

      final getResult = await repository.getEntryById('1');
      expect(getValue(getResult), isNull);
    });

    test('should fail to delete non-existent entry', () async {
      final result = await repository.deleteEntry('non-existent');

      expect(isFailure(result), isTrue);
    });

    test('should return empty list when no entries exist', () async {
      final result = await repository.getAllEntries();

      expect(isSuccess(result), isTrue);
      expect(getValue(result), isEmpty);
    });
  });

  group('VaultRepository - Search and Filter', () {
    setUp(() async {
      // Create test entries with different timestamps
      final now = DateTime.now();

      await repository.createEntry(
        Entry(
          id: '1',
          title: 'Gmail Account',
          username: 'user@gmail.com',
          password: 'pass1',
          url: 'https://gmail.com',
          notes: 'Personal email',
          categories: ['Personal', 'Email'],
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now.subtract(const Duration(days: 3)),
        ),
      );

      await repository.createEntry(
        Entry(
          id: '2',
          title: 'Facebook',
          username: 'user@example.com',
          password: 'pass2',
          url: 'https://facebook.com',
          categories: ['Social'],
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
      );

      await repository.createEntry(
        Entry(
          id: '3',
          title: 'Work Email',
          username: 'user@work.com',
          password: 'pass3',
          categories: ['Work', 'Email'],
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
      );

      await repository.createEntry(
        Entry(
          id: '4',
          title: 'Gmail Work',
          username: 'work@gmail.com',
          password: 'pass4',
          url: 'https://mail.google.com',
          categories: ['Work'],
          createdAt: now,
          updatedAt: now,
        ),
      );
    });

    test('should search entries by title', () async {
      final result = await repository.searchEntries('Gmail');

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.length, equals(2));
      // Should contain both Gmail entries
      final titles = getValue(result)?.map((e) => e.title).toList();
      expect(titles, contains('Gmail Account'));
      expect(titles, contains('Gmail Work'));
    });

    test('should search entries by username', () async {
      final result = await repository.searchEntries('work.com');

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.length, equals(1));
      expect(getValue(result)?.first.title, equals('Work Email'));
    });

    test('should search entries by URL', () async {
      final result = await repository.searchEntries('facebook');

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.length, equals(1));
      expect(getValue(result)?.first.title, equals('Facebook'));
    });

    test('should search entries by notes', () async {
      final result = await repository.searchEntries('Personal email');

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.length, equals(1));
      expect(getValue(result)?.first.title, equals('Gmail Account'));
    });

    test('should search case-insensitively', () async {
      final result = await repository.searchEntries('GMAIL');

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.length, equals(2));
    });

    test('should return empty list for no matches', () async {
      final result = await repository.searchEntries('NonExistent');

      expect(isSuccess(result), isTrue);
      expect(getValue(result), isEmpty);
    });

    test('should order search results by relevance', () async {
      final result = await repository.searchEntries('Gmail');

      expect(isSuccess(result), isTrue);
      final results = getValue(result)!;
      expect(results.length, equals(2));

      // "Gmail Account" should rank higher than "Gmail Work"
      // because it's an exact word match at the start
      expect(results.first.title, equals('Gmail Account'));
    });

    test('should order search results by date when relevance is equal', () async {
      final result = await repository.searchEntries('Email');

      expect(isSuccess(result), isTrue);
      final results = getValue(result)!;
      expect(results.length, equals(2));

      // Both have "Email" in categories, so should be ordered by date (newer first)
      expect(results.first.title, equals('Work Email'));
      expect(results.last.title, equals('Gmail Account'));
    });

    test('should filter entries by category', () async {
      final result = await repository.getEntriesByCategory('Email');

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.length, equals(2));
    });

    test('should order category results by date', () async {
      final result = await repository.getEntriesByCategory('Email');

      expect(isSuccess(result), isTrue);
      final results = getValue(result)!;

      // Should be ordered by date (newer first)
      expect(results.first.title, equals('Work Email'));
      expect(results.last.title, equals('Gmail Account'));
    });

    test('should return empty list for non-existent category', () async {
      final result = await repository.getEntriesByCategory('Banking');

      expect(isSuccess(result), isTrue);
      expect(getValue(result), isEmpty);
    });

    test('should combine search and category filters with AND logic', () async {
      final result = await repository.searchWithFilters(
        query: 'Gmail',
        category: 'Work',
      );

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.length, equals(1));
      expect(getValue(result)?.first.title, equals('Gmail Work'));
    });

    test('should apply only search filter when category is null', () async {
      final result = await repository.searchWithFilters(
        query: 'Gmail',
        category: null,
      );

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.length, equals(2));
    });

    test('should apply only category filter when query is null', () async {
      final result = await repository.searchWithFilters(
        query: null,
        category: 'Email',
      );

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.length, equals(2));
    });

    test('should apply only category filter when query is empty', () async {
      final result = await repository.searchWithFilters(
        query: '',
        category: 'Work',
      );

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.length, equals(2));
      final titles = getValue(result)?.map((e) => e.title).toList();
      expect(titles, contains('Work Email'));
      expect(titles, contains('Gmail Work'));
    });

    test('should return all entries when both filters are null', () async {
      final result = await repository.searchWithFilters(
        query: null,
        category: null,
      );

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.length, equals(4));
    });

    test(
      'should return empty list when combined filters match nothing',
      () async {
        final result = await repository.searchWithFilters(
          query: 'Facebook',
          category: 'Email',
        );

        expect(isSuccess(result), isTrue);
        expect(getValue(result), isEmpty);
      },
    );

    test(
      'should order combined filter results by relevance and date',
      () async {
        final result = await repository.searchWithFilters(
          query: 'Email',
          category: 'Email',
        );

        expect(isSuccess(result), isTrue);
        final results = getValue(result)!;
        expect(results.length, equals(2));

        // Should be ordered by date (newer first) when relevance is equal
        expect(results.first.title, equals('Work Email'));
        expect(results.last.title, equals('Gmail Account'));
      },
    );
  });

  group('VaultRepository - Favorites', () {
    test('should toggle favorite status', () async {
      final entry = Entry(
        id: '1',
        title: 'Test',
        username: 'user',
        password: 'pass',
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createEntry(entry);

      final result = await repository.toggleFavorite('1');

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.isFavorite, isTrue);

      final toggleAgain = await repository.toggleFavorite('1');
      expect(getValue(toggleAgain)?.isFavorite, isFalse);
    });

    test('should retrieve favorite entries', () async {
      await repository.createEntry(
        Entry(
          id: '1',
          title: 'Favorite 1',
          username: 'user1',
          password: 'pass1',
          isFavorite: true,
          accessCount: 10,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await repository.createEntry(
        Entry(
          id: '2',
          title: 'Not Favorite',
          username: 'user2',
          password: 'pass2',
          isFavorite: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await repository.createEntry(
        Entry(
          id: '3',
          title: 'Favorite 2',
          username: 'user3',
          password: 'pass3',
          isFavorite: true,
          accessCount: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final result = await repository.getFavorites();

      expect(isSuccess(result), isTrue);
      expect(getValue(result)?.length, equals(2));
      // Should be sorted by access count
      expect(getValue(result)?.first.accessCount, equals(10));
      expect(getValue(result)?.last.accessCount, equals(5));
    });

    test('should fail to toggle favorite for non-existent entry', () async {
      final result = await repository.toggleFavorite('non-existent');

      expect(isFailure(result), isTrue);
    });
  });

  group('VaultRepository - Password History', () {
    test('should maintain limit of 10 passwords in history', () async {
      // Create entry with initial password
      final entry = Entry(
        id: '1',
        title: 'Test',
        username: 'user',
        password: 'Password0',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createEntry(entry);

      // Change password 12 times to exceed the limit
      Entry currentEntry = entry;
      for (int i = 1; i <= 12; i++) {
        currentEntry = currentEntry.copyWith(
          password: 'Password$i',
          updatedAt: DateTime.now(),
        );
        final result = await repository.updateEntry(currentEntry);
        currentEntry = getValue(result)!;
      }

      // Verify history has exactly 10 entries
      expect(currentEntry.passwordHistory.length, equals(10));

      // Verify oldest passwords were removed (Password0 and Password1 should be gone)
      final passwords = currentEntry.passwordHistory
          .map((h) => h.password)
          .toList();
      expect(passwords, isNot(contains('Password0')));
      expect(passwords, isNot(contains('Password1')));

      // Verify most recent 10 passwords are kept (Password2 through Password11)
      expect(passwords, contains('Password2'));
      expect(passwords, contains('Password11'));
    });

    test('should include timestamps for each password in history', () async {
      final entry = Entry(
        id: '1',
        title: 'Test',
        username: 'user',
        password: 'OldPassword',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createEntry(entry);

      // Wait a bit to ensure different timestamp
      await Future.delayed(const Duration(milliseconds: 10));

      final beforeUpdate = DateTime.now();

      final updated = entry.copyWith(
        password: 'NewPassword',
        updatedAt: DateTime.now(),
      );

      final result = await repository.updateEntry(updated);

      expect(isSuccess(result), isTrue);
      final updatedEntry = getValue(result)!;

      expect(updatedEntry.passwordHistory.length, equals(1));

      final historyEntry = updatedEntry.passwordHistory.first;
      expect(historyEntry.password, equals('OldPassword'));
      expect(historyEntry.changedAt, isNotNull);

      // Verify timestamp is reasonable (within a few seconds of update)
      expect(
        historyEntry.changedAt.isAfter(
          beforeUpdate.subtract(const Duration(seconds: 1)),
        ),
        isTrue,
      );
      expect(
        historyEntry.changedAt.isBefore(
          DateTime.now().add(const Duration(seconds: 1)),
        ),
        isTrue,
      );
    });

    test('should preserve existing history when adding new password', () async {
      // Create entry with some existing history
      final existingHistory = [
        PasswordHistory(
          password: 'VeryOldPassword',
          changedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        PasswordHistory(
          password: 'OldPassword',
          changedAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
      ];

      final entry = Entry(
        id: '1',
        title: 'Test',
        username: 'user',
        password: 'CurrentPassword',
        passwordHistory: existingHistory,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createEntry(entry);

      final updated = entry.copyWith(
        password: 'NewPassword',
        updatedAt: DateTime.now(),
      );

      final result = await repository.updateEntry(updated);

      expect(isSuccess(result), isTrue);
      final updatedEntry = getValue(result)!;

      // Should have 3 entries now (2 existing + 1 new)
      expect(updatedEntry.passwordHistory.length, equals(3));

      // Verify all passwords are present
      final passwords = updatedEntry.passwordHistory
          .map((h) => h.password)
          .toList();
      expect(passwords, contains('VeryOldPassword'));
      expect(passwords, contains('OldPassword'));
      expect(passwords, contains('CurrentPassword'));
    });

    test('should remove oldest password when limit is reached', () async {
      // Create entry with 10 passwords in history (at the limit)
      final existingHistory = List.generate(
        10,
        (i) => PasswordHistory(
          password: 'Password$i',
          changedAt: DateTime.now().subtract(Duration(days: 10 - i)),
        ),
      );

      final entry = Entry(
        id: '1',
        title: 'Test',
        username: 'user',
        password: 'CurrentPassword',
        passwordHistory: existingHistory,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createEntry(entry);

      // Change password one more time
      final updated = entry.copyWith(
        password: 'NewPassword',
        updatedAt: DateTime.now(),
      );

      final result = await repository.updateEntry(updated);

      expect(isSuccess(result), isTrue);
      final updatedEntry = getValue(result)!;

      // Should still have exactly 10 entries
      expect(updatedEntry.passwordHistory.length, equals(10));

      // Verify oldest password (Password0) was removed
      final passwords = updatedEntry.passwordHistory
          .map((h) => h.password)
          .toList();
      expect(passwords, isNot(contains('Password0')));

      // Verify newest password (CurrentPassword) was added
      expect(passwords, contains('CurrentPassword'));

      // Verify Password1 through Password9 are still present
      for (int i = 1; i <= 9; i++) {
        expect(passwords, contains('Password$i'));
      }
    });
  });
}
