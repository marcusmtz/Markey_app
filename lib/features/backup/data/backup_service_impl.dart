import 'dart:convert';
import 'dart:io';
import '../../../core/errors/failures.dart';
import '../../../core/services/encryption_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/utils/result.dart';
import '../domain/backup_service.dart';
import 'backup_model.dart';

/// Implementation of BackupService
/// Handles encrypted backup creation and restoration of vault data
class BackupServiceImpl implements BackupService {
  final EncryptionService _encryptionService;
  final SecureStorageService _storageService;

  static const String _currentVersion = '1.0';
  static const String _entriesKey = 'entries';
  static const String _settingsKey = 'settings';
  static const String _categoriesKey = 'categories';

  BackupServiceImpl({
    required EncryptionService encryptionService,
    required SecureStorageService storageService,
  }) : _encryptionService = encryptionService,
       _storageService = storageService;

  @override
  Future<Result<String>> createBackup(String masterPassword) async {
    try {
      // Read all data from secure storage
      final entriesResult = await _storageService.read(_entriesKey);
      if (entriesResult is Failure) {
        return Failure(
          BackupError(
            'Failed to read entries',
            entriesResult.errorOrNull.toString(),
          ),
        );
      }
      final entriesJson = (entriesResult as Success<String?>).value ?? '[]';

      final settingsResult = await _storageService.read(_settingsKey);
      if (settingsResult is Failure) {
        return Failure(
          BackupError(
            'Failed to read settings',
            settingsResult.errorOrNull.toString(),
          ),
        );
      }
      final settingsJson = (settingsResult as Success<String?>).value ?? '{}';

      final categoriesResult = await _storageService.read(_categoriesKey);
      if (categoriesResult is Failure) {
        return Failure(
          BackupError(
            'Failed to read categories',
            categoriesResult.errorOrNull.toString(),
          ),
        );
      }
      final categoriesJson =
          (categoriesResult as Success<String?>).value ?? '[]';

      // Parse JSON data
      final entries = jsonDecode(entriesJson) as List<dynamic>;
      final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
      final categories = jsonDecode(categoriesJson) as List<dynamic>;

      // Create backup data structure
      final backupData = BackupData(
        entries: entries.cast<Map<String, dynamic>>(),
        settings: settings,
        categories: categories.cast<Map<String, dynamic>>(),
      );

      // Convert to JSON string
      final dataJson = jsonEncode(backupData.toJson());

      // Generate salt for this backup
      final salt = _encryptionService.generateSalt();

      // Encrypt the data
      final encryptResult = await _encryptionService.encrypt(
        dataJson,
        masterPassword,
      );

      if (encryptResult is Failure) {
        return Failure(
          BackupError(
            'Failed to encrypt backup',
            encryptResult.errorOrNull.toString(),
          ),
        );
      }

      final encryptedData = (encryptResult as Success<String>).value;

      // Create backup model
      final backup = BackupModel(
        version: _currentVersion,
        timestamp: DateTime.now(),
        salt: salt,
        encryptedData: encryptedData,
      );

      // Convert to JSON string
      final backupJson = jsonEncode(backup.toJson());

      return Success(backupJson);
    } catch (e) {
      return Failure(BackupError('Failed to create backup', e.toString()));
    }
  }

  @override
  Future<Result<void>> exportBackup(String backupData, String path) async {
    try {
      // Validate backup data
      try {
        jsonDecode(backupData);
      } catch (e) {
        return Failure(
          BackupError('Invalid backup data', 'Backup data is not valid JSON'),
        );
      }

      // Write to file
      final file = File(path);

      // Create parent directory if it doesn't exist
      final directory = file.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      await file.writeAsString(backupData);

      return const Success(null);
    } catch (e) {
      return Failure(BackupError('Failed to export backup', e.toString()));
    }
  }

  @override
  Future<Result<String>> importBackup(String path) async {
    try {
      final file = File(path);

      // Check if file exists
      if (!await file.exists()) {
        return Failure(
          BackupError('File not found', 'Backup file does not exist at $path'),
        );
      }

      // Read file content
      final backupData = await file.readAsString();

      // Validate JSON format
      try {
        jsonDecode(backupData);
      } catch (e) {
        return Failure(
          BackupError(
            'Invalid backup file',
            'File does not contain valid JSON',
          ),
        );
      }

      return Success(backupData);
    } catch (e) {
      return Failure(BackupError('Failed to import backup', e.toString()));
    }
  }

  @override
  Future<Result<void>> restoreBackup(
    String backupData,
    String masterPassword,
  ) async {
    try {
      // Parse backup JSON
      final backupJson = jsonDecode(backupData) as Map<String, dynamic>;
      final backup = BackupModel.fromJson(backupJson);

      // Validate version
      if (backup.version != _currentVersion) {
        return Failure(
          BackupError(
            'Unsupported backup version',
            'Backup version ${backup.version} is not supported. Current version: $_currentVersion',
          ),
        );
      }

      // Decrypt the data
      final decryptResult = await _encryptionService.decrypt(
        backup.encryptedData,
        masterPassword,
      );

      if (decryptResult is Failure) {
        return Failure(
          BackupError(
            'Failed to decrypt backup',
            'Invalid password or corrupted backup data',
          ),
        );
      }

      final decryptedJson = (decryptResult as Success<String>).value;

      // Parse decrypted data
      BackupData restoredData;
      try {
        final dataJson = jsonDecode(decryptedJson) as Map<String, dynamic>;
        restoredData = BackupData.fromJson(dataJson);
      } catch (e) {
        return Failure(
          BackupError(
            'Corrupted backup data',
            'Backup data structure is invalid',
          ),
        );
      }

      // Backup existing data before restoration (in case of failure)
      final existingEntriesResult = await _storageService.read(_entriesKey);
      final existingSettingsResult = await _storageService.read(_settingsKey);
      final existingCategoriesResult = await _storageService.read(
        _categoriesKey,
      );

      // Write restored data to secure storage
      try {
        // Write entries
        final entriesJson = jsonEncode(restoredData.entries);
        final writeEntriesResult = await _storageService.write(
          _entriesKey,
          entriesJson,
        );
        if (writeEntriesResult is Failure) {
          throw Exception('Failed to write entries');
        }

        // Write settings
        final settingsJson = jsonEncode(restoredData.settings);
        final writeSettingsResult = await _storageService.write(
          _settingsKey,
          settingsJson,
        );
        if (writeSettingsResult is Failure) {
          throw Exception('Failed to write settings');
        }

        // Write categories
        final categoriesJson = jsonEncode(restoredData.categories);
        final writeCategoriesResult = await _storageService.write(
          _categoriesKey,
          categoriesJson,
        );
        if (writeCategoriesResult is Failure) {
          throw Exception('Failed to write categories');
        }

        return const Success(null);
      } catch (e) {
        // Restore original data if restoration failed
        if (existingEntriesResult is Success<String?> &&
            existingEntriesResult.value != null) {
          await _storageService.write(
            _entriesKey,
            existingEntriesResult.value!,
          );
        }
        if (existingSettingsResult is Success<String?> &&
            existingSettingsResult.value != null) {
          await _storageService.write(
            _settingsKey,
            existingSettingsResult.value!,
          );
        }
        if (existingCategoriesResult is Success<String?> &&
            existingCategoriesResult.value != null) {
          await _storageService.write(
            _categoriesKey,
            existingCategoriesResult.value!,
          );
        }

        return Failure(
          BackupError(
            'Failed to restore backup',
            'Restoration failed, existing data preserved',
          ),
        );
      }
    } catch (e) {
      return Failure(BackupError('Failed to restore backup', e.toString()));
    }
  }
}
