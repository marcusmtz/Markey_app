import 'dart:typed_data';
import '../utils/result.dart';

/// Abstract interface for encryption operations
abstract class EncryptionService {
  /// Encrypts a plaintext string using the provided master key
  /// Returns encrypted data in format: salt:iv:ciphertext:tag
  Future<Result<String>> encrypt(String plaintext, String masterKey);

  /// Decrypts a ciphertext string using the provided master key
  /// Expects format: salt:iv:ciphertext:tag
  Future<Result<String>> decrypt(String ciphertext, String masterKey);

  /// Encrypts binary data (for files) using the provided master key
  /// Returns encrypted bytes with prepended salt and IV
  Future<Result<Uint8List>> encryptBytes(Uint8List data, String masterKey);

  /// Decrypts binary data (for files) using the provided master key
  /// Expects encrypted bytes with prepended salt and IV
  Future<Result<Uint8List>> decryptBytes(Uint8List data, String masterKey);

  /// Derives a master key from password and salt using PBKDF2
  /// Uses 100,000 iterations as specified
  String deriveMasterKey(String password, String salt);

  /// Generates a cryptographically secure random salt
  String generateSalt();

  /// Generates a cryptographically secure random IV
  String generateIV();
}
