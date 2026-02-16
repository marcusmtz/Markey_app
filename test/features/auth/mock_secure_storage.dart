import 'package:markey_app/core/errors/failures.dart';
import 'package:markey_app/core/services/secure_storage_service.dart';
import 'package:markey_app/core/utils/result.dart';

/// Mock implementation of SecureStorageService for testing
/// Uses in-memory storage instead of platform-specific secure storage
class MockSecureStorage implements SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<Result<void>> write(String key, String value) async {
    _storage[key] = value;
    return const Success(null);
  }

  @override
  Future<Result<String?>> read(String key) async {
    return Success(_storage[key]);
  }

  @override
  Future<Result<void>> delete(String key) async {
    _storage.remove(key);
    return const Success(null);
  }

  @override
  Future<Result<bool>> containsKey(String key) async {
    return Success(_storage.containsKey(key));
  }

  @override
  Future<Result<void>> deleteAll() async {
    _storage.clear();
    return const Success(null);
  }

  @override
  Future<Result<Map<String, String>>> readAll() async {
    return Success(Map.from(_storage));
  }

  @override
  Future<bool> isStorageAvailable() async {
    return true;
  }
}
