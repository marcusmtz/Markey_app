import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../errors/failures.dart';
import '../utils/result.dart';
import 'secure_storage_service.dart';

/// Implementation of SecureStorageService using flutter_secure_storage
/// Provides secure storage for sensitive data like encryption keys and hashes
class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _storage;

  /// Storage keys used by the application
  static const String masterPasswordHashKey = 'master_password_hash';
  static const String masterPinHashKey = 'master_pin_hash';
  static const String encryptionSaltKey = 'encryption_salt';
  static const String biometricsEnabledKey = 'biometrics_enabled';
  static const String entriesKey = 'entries';
  static const String categoriesKey = 'categories';
  static const String settingsKey = 'settings';

  SecureStorageServiceImpl({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  @override
  Future<Result<void>> write(String key, String value) async {
    try {
      // Check if storage is available
      final available = await isStorageAvailable();
      if (!available) {
        return Failure(
          StorageError(
            'Secure storage not available',
            'The device does not support secure storage or it is not accessible',
          ),
        );
      }

      await _storage.write(key: key, value: value);
      return const Success(null);
    } catch (e) {
      return Failure(
        StorageError('Failed to write to secure storage', e.toString()),
      );
    }
  }

  @override
  Future<Result<String?>> read(String key) async {
    try {
      // Check if storage is available
      final available = await isStorageAvailable();
      if (!available) {
        return Failure(
          StorageError(
            'Secure storage not available',
            'The device does not support secure storage or it is not accessible',
          ),
        );
      }

      final value = await _storage.read(key: key);
      return Success(value);
    } catch (e) {
      return Failure(
        StorageError('Failed to read from secure storage', e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> delete(String key) async {
    try {
      // Check if storage is available
      final available = await isStorageAvailable();
      if (!available) {
        return Failure(
          StorageError(
            'Secure storage not available',
            'The device does not support secure storage or it is not accessible',
          ),
        );
      }

      await _storage.delete(key: key);
      return const Success(null);
    } catch (e) {
      return Failure(
        StorageError('Failed to delete from secure storage', e.toString()),
      );
    }
  }

  @override
  Future<Result<bool>> containsKey(String key) async {
    try {
      // Check if storage is available
      final available = await isStorageAvailable();
      if (!available) {
        return Failure(
          StorageError(
            'Secure storage not available',
            'The device does not support secure storage or it is not accessible',
          ),
        );
      }

      final value = await _storage.containsKey(key: key);
      return Success(value);
    } catch (e) {
      return Failure(
        StorageError('Failed to check key in secure storage', e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> deleteAll() async {
    try {
      // Check if storage is available
      final available = await isStorageAvailable();
      if (!available) {
        return Failure(
          StorageError(
            'Secure storage not available',
            'The device does not support secure storage or it is not accessible',
          ),
        );
      }

      await _storage.deleteAll();
      return const Success(null);
    } catch (e) {
      return Failure(
        StorageError('Failed to delete all from secure storage', e.toString()),
      );
    }
  }

  @override
  Future<Result<Map<String, String>>> readAll() async {
    try {
      // Check if storage is available
      final available = await isStorageAvailable();
      if (!available) {
        return Failure(
          StorageError(
            'Secure storage not available',
            'The device does not support secure storage or it is not accessible',
          ),
        );
      }

      final allValues = await _storage.readAll();
      return Success(allValues);
    } catch (e) {
      return Failure(
        StorageError('Failed to read all from secure storage', e.toString()),
      );
    }
  }

  @override
  Future<bool> isStorageAvailable() async {
    try {
      // Try to perform a simple operation to check if storage is available
      // We'll try to read a non-existent key - if it doesn't throw, storage is available
      await _storage.containsKey(key: '__storage_check__');
      return true;
    } catch (e) {
      // If any error occurs, storage is not available
      return false;
    }
  }
}
