import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:markey_app/core/services/encryption_service.dart';
import 'package:markey_app/core/services/encryption_service_impl.dart';
import 'package:markey_app/core/services/secure_storage_service.dart';
import 'package:markey_app/core/utils/result.dart';
import 'package:markey_app/features/backup/data/backup_service_impl.dart';
import 'package:markey_app/features/backup/domain/backup_service.dart';
import '../auth/mock_secure_storage.dart';

void main() {
  late BackupService backupService;
  late EncryptionService encryptionService;
  late SecureStorageService storageService;

  setUp(() {
    encryptionService = EncryptionServiceImpl();
    storageService = MockSecureStorage();
    backupService = BackupServiceImpl(
      encryptionService: encryptionService,
      storageService: storageService,
    );
  });

  group('BackupService - Unit Tests', () {
    const testPassword = 'TestMasterPassword123!';

    test('should create backup with one entry', () async {
      // Setup: Add one entry to storage
      final entry = {
        'id': '1',
        'encryptedData': 'encrypted_entry_data',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await storageService.write('entries', jsonEncode([entry]));
      await storageService.write('settings', jsonEncode({}));
      await storageService.write('categories', jsonEncode([]));

      // Execute
      final result = await backupService.createBackup(testPassword);

      // Verify
      expect(result.isSuccess, isTrue);
      final backupData = result.valueOrNull!;
      expect(backupData, isNotEmpty);

      // Verify backup structure
      final backupJson = jsonDecode(backupData) as Map<String, dynamic>;
      expect(backupJson['version'], equals('1.0'));
      expect(backupJson['timestamp'], isNotNull);
      expect(backupJson['salt'], isNotNull);
      expect(backupJson['data'], isNotNull);
    });

    test('should create backup with multiple entries', () async {
      // Setup: Add multiple entries to storage
      final entries = [
        {
          'id': '1',
          'encryptedData': 'encrypted_entry_1',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'encryptedData': 'encrypted_entry_2',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        {
          'id': '3',
          'encryptedData': 'encrypted_entry_3',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      ];

      // Clear storage first
      await storageService.deleteAll();

      await storageService.write('entries', jsonEncode(entries));
      await storageService.write('settings', jsonEncode({'theme': 'dark'}));
      await storageService.write(
        'categories',
        jsonEncode([
          {
            'id': '1',
            'name': 'Work',
            'colorHex': '#2196F3',
            'isPredefined': true,
          },
          {
            'id': '2',
            'name': 'Personal',
            'colorHex': '#4CAF50',
            'isPredefined': true,
          },
        ]),
      );

      // Execute
      final result = await backupService.createBackup(testPassword);

      // Verify
      if (result.isFailure) {
        print('Backup creation failed: ${result.errorOrNull}');
      }
      expect(result.isSuccess, isTrue);
      final backupData = result.valueOrNull!;
      expect(backupData, isNotEmpty);

      // Verify backup can be parsed
      final backupJson = jsonDecode(backupData) as Map<String, dynamic>;
      expect(backupJson['version'], equals('1.0'));
      expect(backupJson['data'], isNotEmpty);
    });

    test('should restore backup with correct password', () async {
      // Clear storage first
      await storageService.deleteAll();

      // Setup: Create a backup
      final entries = [
        {
          'id': '1',
          'encryptedData': 'encrypted_entry_1',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      ];
      await storageService.write('entries', jsonEncode(entries));
      await storageService.write('settings', jsonEncode({'theme': 'light'}));
      await storageService.write(
        'categories',
        jsonEncode([
          {
            'id': '3',
            'name': 'Banking',
            'colorHex': '#FF9800',
            'isPredefined': true,
          },
        ]),
      );

      final createResult = await backupService.createBackup(testPassword);
      if (createResult.isFailure) {
        print('Backup creation failed: ${createResult.errorOrNull}');
      }
      expect(createResult.isSuccess, isTrue);
      final backupData = createResult.valueOrNull!;

      // Clear storage
      await storageService.deleteAll();

      // Execute: Restore backup
      final restoreResult = await backupService.restoreBackup(
        backupData,
        testPassword,
      );

      // Verify
      if (restoreResult.isFailure) {
        print('Restore failed: ${restoreResult.errorOrNull}');
      }
      expect(restoreResult.isSuccess, isTrue);

      // Verify data was restored
      final entriesResult = await storageService.read('entries');
      expect(entriesResult.isSuccess, isTrue);
      final restoredEntries = jsonDecode(entriesResult.valueOrNull!) as List;
      expect(restoredEntries.length, equals(1));
      expect(restoredEntries[0]['id'], equals('1'));

      final settingsResult = await storageService.read('settings');
      expect(settingsResult.isSuccess, isTrue);
      final restoredSettings =
          jsonDecode(settingsResult.valueOrNull!) as Map<String, dynamic>;
      expect(restoredSettings['theme'], equals('light'));

      final categoriesResult = await storageService.read('categories');
      expect(categoriesResult.isSuccess, isTrue);
      final restoredCategories =
          jsonDecode(categoriesResult.valueOrNull!) as List;
      expect(restoredCategories.length, equals(1));
      expect(restoredCategories[0]['name'], equals('Banking'));
    });

    test('should fail to restore backup with incorrect password', () async {
      // Setup: Create a backup
      await storageService.write('entries', jsonEncode([]));
      await storageService.write('settings', jsonEncode({}));
      await storageService.write('categories', jsonEncode([]));

      final createResult = await backupService.createBackup(testPassword);
      expect(createResult.isSuccess, isTrue);
      final backupData = createResult.valueOrNull!;

      // Execute: Try to restore with wrong password
      final restoreResult = await backupService.restoreBackup(
        backupData,
        'WrongPassword123!',
      );

      // Verify
      expect(restoreResult.isFailure, isTrue);
      expect(
        restoreResult.errorOrNull!.message,
        contains('Failed to decrypt backup'),
      );
    });

    test('should fail to restore corrupted backup', () async {
      // Setup: Create corrupted backup data
      final corruptedBackup = jsonEncode({
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'salt': 'some_salt',
        'data': 'corrupted_encrypted_data_that_cannot_be_decrypted',
      });

      // Execute
      final restoreResult = await backupService.restoreBackup(
        corruptedBackup,
        testPassword,
      );

      // Verify
      expect(restoreResult.isFailure, isTrue);
    });

    test('should export backup to file', () async {
      // Setup: Create a backup
      await storageService.write('entries', jsonEncode([]));
      await storageService.write('settings', jsonEncode({}));
      await storageService.write('categories', jsonEncode([]));

      final createResult = await backupService.createBackup(testPassword);
      expect(createResult.isSuccess, isTrue);
      final backupData = createResult.valueOrNull!;

      // Create temp directory for test
      final tempDir = Directory.systemTemp.createTempSync('backup_test_');
      final backupPath = '${tempDir.path}/test_backup.json';

      try {
        // Execute
        final exportResult = await backupService.exportBackup(
          backupData,
          backupPath,
        );

        // Verify
        expect(exportResult.isSuccess, isTrue);

        // Verify file exists and contains data
        final file = File(backupPath);
        expect(await file.exists(), isTrue);

        final fileContent = await file.readAsString();
        expect(fileContent, equals(backupData));
      } finally {
        // Cleanup
        await tempDir.delete(recursive: true);
      }
    });

    test('should import backup from file', () async {
      // Setup: Create a backup and export it
      await storageService.write('entries', jsonEncode([]));
      await storageService.write('settings', jsonEncode({}));
      await storageService.write('categories', jsonEncode([]));

      final createResult = await backupService.createBackup(testPassword);
      expect(createResult.isSuccess, isTrue);
      final backupData = createResult.valueOrNull!;

      // Create temp directory and file
      final tempDir = Directory.systemTemp.createTempSync('backup_test_');
      final backupPath = '${tempDir.path}/test_backup.json';
      final file = File(backupPath);
      await file.writeAsString(backupData);

      try {
        // Execute
        final importResult = await backupService.importBackup(backupPath);

        // Verify
        expect(importResult.isSuccess, isTrue);
        final importedData = importResult.valueOrNull!;
        expect(importedData, equals(backupData));
      } finally {
        // Cleanup
        await tempDir.delete(recursive: true);
      }
    });

    test('should fail to import from non-existent file', () async {
      // Execute
      final importResult = await backupService.importBackup(
        '/non/existent/path/backup.json',
      );

      // Verify
      expect(importResult.isFailure, isTrue);
      expect(importResult.errorOrNull!.message, contains('File not found'));
    });

    test('should preserve existing data when restore fails', () async {
      // Setup: Add existing data
      final existingEntries = [
        {
          'id': 'existing_1',
          'encryptedData': 'existing_data',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      ];
      await storageService.write('entries', jsonEncode(existingEntries));
      await storageService.write('settings', jsonEncode({'theme': 'dark'}));
      await storageService.write('categories', jsonEncode(['Existing']));

      // Create corrupted backup
      final corruptedBackup = jsonEncode({
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'salt': 'some_salt',
        'data': 'corrupted_data',
      });

      // Execute: Try to restore corrupted backup
      final restoreResult = await backupService.restoreBackup(
        corruptedBackup,
        testPassword,
      );

      // Verify restore failed
      expect(restoreResult.isFailure, isTrue);

      // Verify existing data is still there
      final entriesResult = await storageService.read('entries');
      expect(entriesResult.isSuccess, isTrue);
      final entries = jsonDecode(entriesResult.valueOrNull!) as List;
      expect(entries.length, equals(1));
      expect(entries[0]['id'], equals('existing_1'));
    });

    test('should handle empty vault backup', () async {
      // Setup: Empty vault
      await storageService.write('entries', jsonEncode([]));
      await storageService.write('settings', jsonEncode({}));
      await storageService.write('categories', jsonEncode([]));

      // Execute: Create backup
      final createResult = await backupService.createBackup(testPassword);

      // Verify
      expect(createResult.isSuccess, isTrue);
      final backupData = createResult.valueOrNull!;

      // Execute: Restore backup
      final restoreResult = await backupService.restoreBackup(
        backupData,
        testPassword,
      );

      // Verify
      expect(restoreResult.isSuccess, isTrue);

      // Verify empty data was restored
      final entriesResult = await storageService.read('entries');
      expect(entriesResult.isSuccess, isTrue);
      final entries = jsonDecode(entriesResult.valueOrNull!) as List;
      expect(entries.isEmpty, isTrue);
    });

    test('should fail to export invalid backup data', () async {
      // Execute: Try to export invalid JSON
      final exportResult = await backupService.exportBackup(
        'invalid json data {{{',
        '/tmp/backup.json',
      );

      // Verify
      expect(exportResult.isFailure, isTrue);
      expect(
        exportResult.errorOrNull!.message,
        contains('Invalid backup data'),
      );
    });

    test('should fail to import file with invalid JSON', () async {
      // Setup: Create file with invalid JSON
      final tempDir = Directory.systemTemp.createTempSync('backup_test_');
      final backupPath = '${tempDir.path}/invalid_backup.json';
      final file = File(backupPath);
      await file.writeAsString('invalid json {{{');

      try {
        // Execute
        final importResult = await backupService.importBackup(backupPath);

        // Verify
        expect(importResult.isFailure, isTrue);
        expect(
          importResult.errorOrNull!.message,
          contains('Invalid backup file'),
        );
      } finally {
        // Cleanup
        await tempDir.delete(recursive: true);
      }
    });

    test('should include timestamp in backup', () async {
      // Setup
      await storageService.write('entries', jsonEncode([]));
      await storageService.write('settings', jsonEncode({}));
      await storageService.write('categories', jsonEncode([]));

      final beforeBackup = DateTime.now();

      // Execute
      final result = await backupService.createBackup(testPassword);

      final afterBackup = DateTime.now();

      // Verify
      expect(result.isSuccess, isTrue);
      final backupData = result.valueOrNull!;
      final backupJson = jsonDecode(backupData) as Map<String, dynamic>;
      final timestamp = DateTime.parse(backupJson['timestamp'] as String);

      expect(
        timestamp.isAfter(beforeBackup.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        timestamp.isBefore(afterBackup.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('should fail to restore backup with unsupported version', () async {
      // Setup: Create backup with unsupported version
      final unsupportedBackup = jsonEncode({
        'version': '2.0',
        'timestamp': DateTime.now().toIso8601String(),
        'salt': 'some_salt',
        'data': 'some_data',
      });

      // Execute
      final restoreResult = await backupService.restoreBackup(
        unsupportedBackup,
        testPassword,
      );

      // Verify
      expect(restoreResult.isFailure, isTrue);
      expect(
        restoreResult.errorOrNull!.message,
        contains('Unsupported backup version'),
      );
    });
  });
}
