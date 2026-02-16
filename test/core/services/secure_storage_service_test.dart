import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:markey_app/core/services/secure_storage_service.dart';
import 'package:markey_app/core/services/secure_storage_service_impl.dart';
import 'package:markey_app/core/utils/result.dart';

/// Mock implementation of FlutterSecureStorage for testing
class MockFlutterSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _storage = {};
  bool _isAvailable = true;

  void setAvailable(bool available) {
    _isAvailable = available;
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (!_isAvailable) {
      throw Exception('Storage not available');
    }
    if (value != null) {
      _storage[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (!_isAvailable) {
      throw Exception('Storage not available');
    }
    return _storage[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (!_isAvailable) {
      throw Exception('Storage not available');
    }
    _storage.remove(key);
  }

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (!_isAvailable) {
      throw Exception('Storage not available');
    }
    return _storage.containsKey(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (!_isAvailable) {
      throw Exception('Storage not available');
    }
    _storage.clear();
  }

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (!_isAvailable) {
      throw Exception('Storage not available');
    }
    return Map.from(_storage);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late SecureStorageService secureStorageService;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    secureStorageService = SecureStorageServiceImpl(storage: mockStorage);
  });

  group('SecureStorageService', () {
    const testKey = 'test_key';
    const testValue = 'test_value';

    test('should write and read data successfully', () async {
      final writeResult = await secureStorageService.write(testKey, testValue);
      expect(writeResult.isSuccess, isTrue);

      final readResult = await secureStorageService.read(testKey);
      expect(readResult.isSuccess, isTrue);
      expect(readResult.valueOrNull, equals(testValue));
    });

    test('should return null when reading non-existent key', () async {
      final readResult = await secureStorageService.read('non_existent_key');
      expect(readResult.isSuccess, isTrue);
      expect(readResult.valueOrNull, isNull);
    });

    test('should delete data successfully', () async {
      await secureStorageService.write(testKey, testValue);

      final deleteResult = await secureStorageService.delete(testKey);
      expect(deleteResult.isSuccess, isTrue);

      final readResult = await secureStorageService.read(testKey);
      expect(readResult.isSuccess, isTrue);
      expect(readResult.valueOrNull, isNull);
    });

    test('should check if key exists', () async {
      await secureStorageService.write(testKey, testValue);

      final containsResult = await secureStorageService.containsKey(testKey);
      expect(containsResult.isSuccess, isTrue);
      expect(containsResult.valueOrNull, isTrue);

      final notContainsResult = await secureStorageService.containsKey(
        'non_existent',
      );
      expect(notContainsResult.isSuccess, isTrue);
      expect(notContainsResult.valueOrNull, isFalse);
    });

    test('should delete all data', () async {
      await secureStorageService.write('key1', 'value1');
      await secureStorageService.write('key2', 'value2');
      await secureStorageService.write('key3', 'value3');

      final deleteAllResult = await secureStorageService.deleteAll();
      expect(deleteAllResult.isSuccess, isTrue);

      final readAllResult = await secureStorageService.readAll();
      expect(readAllResult.isSuccess, isTrue);
      expect(readAllResult.valueOrNull, isEmpty);
    });

    test('should read all data', () async {
      await secureStorageService.write('key1', 'value1');
      await secureStorageService.write('key2', 'value2');
      await secureStorageService.write('key3', 'value3');

      final readAllResult = await secureStorageService.readAll();
      expect(readAllResult.isSuccess, isTrue);

      final allData = readAllResult.valueOrNull!;
      expect(allData.length, equals(3));
      expect(allData['key1'], equals('value1'));
      expect(allData['key2'], equals('value2'));
      expect(allData['key3'], equals('value3'));
    });

    test('should check if storage is available', () async {
      final isAvailable = await secureStorageService.isStorageAvailable();
      expect(isAvailable, isTrue);
    });

    test('should handle storage not available error on write', () async {
      mockStorage.setAvailable(false);

      final writeResult = await secureStorageService.write(testKey, testValue);
      expect(writeResult.isFailure, isTrue);
      expect(writeResult.errorOrNull?.message, contains('not available'));
    });

    test('should handle storage not available error on read', () async {
      mockStorage.setAvailable(false);

      final readResult = await secureStorageService.read(testKey);
      expect(readResult.isFailure, isTrue);
      expect(readResult.errorOrNull?.message, contains('not available'));
    });

    test('should handle storage not available error on delete', () async {
      mockStorage.setAvailable(false);

      final deleteResult = await secureStorageService.delete(testKey);
      expect(deleteResult.isFailure, isTrue);
      expect(deleteResult.errorOrNull?.message, contains('not available'));
    });

    test('should handle storage not available error on containsKey', () async {
      mockStorage.setAvailable(false);

      final containsResult = await secureStorageService.containsKey(testKey);
      expect(containsResult.isFailure, isTrue);
      expect(containsResult.errorOrNull?.message, contains('not available'));
    });

    test('should handle storage not available error on deleteAll', () async {
      mockStorage.setAvailable(false);

      final deleteAllResult = await secureStorageService.deleteAll();
      expect(deleteAllResult.isFailure, isTrue);
      expect(deleteAllResult.errorOrNull?.message, contains('not available'));
    });

    test('should handle storage not available error on readAll', () async {
      mockStorage.setAvailable(false);

      final readAllResult = await secureStorageService.readAll();
      expect(readAllResult.isFailure, isTrue);
      expect(readAllResult.errorOrNull?.message, contains('not available'));
    });

    test('should return false when storage is not available', () async {
      mockStorage.setAvailable(false);

      final isAvailable = await secureStorageService.isStorageAvailable();
      expect(isAvailable, isFalse);
    });

    test('should store and retrieve master password hash', () async {
      const hash = 'hashed_master_password';

      final writeResult = await secureStorageService.write(
        SecureStorageServiceImpl.masterPasswordHashKey,
        hash,
      );
      expect(writeResult.isSuccess, isTrue);

      final readResult = await secureStorageService.read(
        SecureStorageServiceImpl.masterPasswordHashKey,
      );
      expect(readResult.isSuccess, isTrue);
      expect(readResult.valueOrNull, equals(hash));
    });

    test('should store and retrieve encryption salt', () async {
      const salt = 'random_encryption_salt';

      final writeResult = await secureStorageService.write(
        SecureStorageServiceImpl.encryptionSaltKey,
        salt,
      );
      expect(writeResult.isSuccess, isTrue);

      final readResult = await secureStorageService.read(
        SecureStorageServiceImpl.encryptionSaltKey,
      );
      expect(readResult.isSuccess, isTrue);
      expect(readResult.valueOrNull, equals(salt));
    });

    test('should store and retrieve biometrics enabled flag', () async {
      const enabled = 'true';

      final writeResult = await secureStorageService.write(
        SecureStorageServiceImpl.biometricsEnabledKey,
        enabled,
      );
      expect(writeResult.isSuccess, isTrue);

      final readResult = await secureStorageService.read(
        SecureStorageServiceImpl.biometricsEnabledKey,
      );
      expect(readResult.isSuccess, isTrue);
      expect(readResult.valueOrNull, equals(enabled));
    });

    test('should overwrite existing value', () async {
      await secureStorageService.write(testKey, 'old_value');
      await secureStorageService.write(testKey, 'new_value');

      final readResult = await secureStorageService.read(testKey);
      expect(readResult.isSuccess, isTrue);
      expect(readResult.valueOrNull, equals('new_value'));
    });

    test('should handle empty string values', () async {
      final writeResult = await secureStorageService.write(testKey, '');
      expect(writeResult.isSuccess, isTrue);

      final readResult = await secureStorageService.read(testKey);
      expect(readResult.isSuccess, isTrue);
      expect(readResult.valueOrNull, equals(''));
    });

    test('should handle special characters in values', () async {
      const specialValue = '!@#\$%^&*()_+-=[]{}|;:,.<>?/~`"\'\\';

      final writeResult = await secureStorageService.write(
        testKey,
        specialValue,
      );
      expect(writeResult.isSuccess, isTrue);

      final readResult = await secureStorageService.read(testKey);
      expect(readResult.isSuccess, isTrue);
      expect(readResult.valueOrNull, equals(specialValue));
    });

    test('should handle Unicode characters in values', () async {
      const unicodeValue = 'Hello 世界 🌍 Привет مرحبا';

      final writeResult = await secureStorageService.write(
        testKey,
        unicodeValue,
      );
      expect(writeResult.isSuccess, isTrue);

      final readResult = await secureStorageService.read(testKey);
      expect(readResult.isSuccess, isTrue);
      expect(readResult.valueOrNull, equals(unicodeValue));
    });
  });
}
