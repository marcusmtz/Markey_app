import '../utils/result.dart';

/// Abstract interface for secure storage operations
/// Manages encrypted storage of sensitive data using flutter_secure_storage
abstract class SecureStorageService {
  /// Saves encrypted data to secure storage
  /// [key] - The storage key
  /// [value] - The encrypted value to store
  Future<Result<void>> write(String key, String value);

  /// Reads encrypted data from secure storage
  /// [key] - The storage key
  /// Returns the encrypted value or null if not found
  Future<Result<String?>> read(String key);

  /// Deletes data from secure storage
  /// [key] - The storage key to delete
  Future<Result<void>> delete(String key);

  /// Checks if a key exists in secure storage
  /// [key] - The storage key to check
  Future<Result<bool>> containsKey(String key);

  /// Deletes all data from secure storage
  /// Use with caution - this will remove all stored data
  Future<Result<void>> deleteAll();

  /// Reads all keys from secure storage
  /// Returns a map of all key-value pairs
  Future<Result<Map<String, String>>> readAll();

  /// Checks if secure storage is available on the device
  /// Returns true if storage is available, false otherwise
  Future<bool> isStorageAvailable();
}
