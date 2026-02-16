import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_lib;
import '../errors/failures.dart';
import '../utils/result.dart';
import 'encryption_service.dart';

/// Implementation of EncryptionService using AES-256-GCM
class EncryptionServiceImpl implements EncryptionService {
  static const int _saltLength = 32; // 256 bits
  static const int _ivLength = 16; // 128 bits for AES
  static const int _keyLength = 32; // 256 bits for AES-256
  static const int _pbkdf2Iterations = 100000;

  final Random _secureRandom = Random.secure();

  @override
  Future<Result<String>> encrypt(String plaintext, String masterKey) async {
    try {
      // Generate random salt and IV
      final salt = generateSalt();
      final iv = generateIV();

      // Derive encryption key from master key and salt
      final derivedKey = deriveMasterKey(masterKey, salt);

      // Convert derived key to bytes (it's hex string)
      final keyBytes = _hexToBytes(derivedKey);
      final key = encrypt_lib.Key(keyBytes);
      final ivObj = encrypt_lib.IV.fromBase64(iv);

      // Create encrypter with AES-256-GCM
      final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(key, mode: encrypt_lib.AESMode.gcm),
      );

      // Encrypt the plaintext
      final encrypted = encrypter.encrypt(plaintext, iv: ivObj);

      // Format: salt:iv:ciphertext:tag
      // Note: encrypt library's GCM mode includes the tag in the encrypted output
      final result = '$salt:$iv:${encrypted.base64}';

      return Success(result);
    } catch (e) {
      return Failure(EncryptionError('Failed to encrypt data', e.toString()));
    }
  }

  @override
  Future<Result<String>> decrypt(String ciphertext, String masterKey) async {
    try {
      // Parse format: salt:iv:ciphertext:tag
      final parts = ciphertext.split(':');
      if (parts.length != 3) {
        return Failure(
          EncryptionError(
            'Invalid ciphertext format',
            'Expected format: salt:iv:ciphertext',
          ),
        );
      }

      final salt = parts[0];
      final iv = parts[1];
      final encryptedData = parts[2];

      // Derive encryption key from master key and salt
      final derivedKey = deriveMasterKey(masterKey, salt);

      // Convert derived key to bytes
      final keyBytes = _hexToBytes(derivedKey);
      final key = encrypt_lib.Key(keyBytes);
      final ivObj = encrypt_lib.IV.fromBase64(iv);

      // Create encrypter with AES-256-GCM
      final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(key, mode: encrypt_lib.AESMode.gcm),
      );

      // Decrypt the ciphertext
      final encrypted = encrypt_lib.Encrypted.fromBase64(encryptedData);
      final decrypted = encrypter.decrypt(encrypted, iv: ivObj);

      return Success(decrypted);
    } catch (e) {
      return Failure(EncryptionError('Failed to decrypt data', e.toString()));
    }
  }

  @override
  Future<Result<Uint8List>> encryptBytes(
    Uint8List data,
    String masterKey,
  ) async {
    try {
      // Generate random salt and IV
      final salt = generateSalt();
      final iv = generateIV();

      // Derive encryption key from master key and salt
      final derivedKey = deriveMasterKey(masterKey, salt);

      // Convert derived key to bytes
      final keyBytes = _hexToBytes(derivedKey);
      final key = encrypt_lib.Key(keyBytes);
      final ivObj = encrypt_lib.IV.fromBase64(iv);

      // Create encrypter with AES-256-GCM
      final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(key, mode: encrypt_lib.AESMode.gcm),
      );

      // Encrypt the bytes
      final encrypted = encrypter.encryptBytes(data.toList(), iv: ivObj);

      // Prepend salt and IV to encrypted data
      // Format: [salt_bytes][iv_bytes][encrypted_bytes]
      final saltBytes = base64.decode(salt);
      final ivBytes = base64.decode(iv);
      final encryptedBytes = encrypted.bytes;

      final result = Uint8List.fromList([
        ...saltBytes,
        ...ivBytes,
        ...encryptedBytes,
      ]);

      return Success(result);
    } catch (e) {
      return Failure(EncryptionError('Failed to encrypt bytes', e.toString()));
    }
  }

  @override
  Future<Result<Uint8List>> decryptBytes(
    Uint8List data,
    String masterKey,
  ) async {
    try {
      // Extract salt, IV, and encrypted data
      // Format: [salt_bytes][iv_bytes][encrypted_bytes]
      if (data.length < _saltLength + _ivLength) {
        return Failure(
          EncryptionError(
            'Invalid encrypted data',
            'Data too short to contain salt and IV',
          ),
        );
      }

      final saltBytes = data.sublist(0, _saltLength);
      final ivBytes = data.sublist(_saltLength, _saltLength + _ivLength);
      final encryptedBytes = data.sublist(_saltLength + _ivLength);

      // Convert salt to base64 for key derivation
      final salt = base64.encode(saltBytes);

      // Derive encryption key from master key and salt
      final derivedKey = deriveMasterKey(masterKey, salt);

      // Convert derived key to bytes
      final keyBytes = _hexToBytes(derivedKey);
      final key = encrypt_lib.Key(keyBytes);
      final ivObj = encrypt_lib.IV(ivBytes);

      // Create encrypter with AES-256-GCM
      final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(key, mode: encrypt_lib.AESMode.gcm),
      );

      // Decrypt the bytes
      final encrypted = encrypt_lib.Encrypted(encryptedBytes);
      final decrypted = encrypter.decryptBytes(encrypted, iv: ivObj);

      return Success(Uint8List.fromList(decrypted));
    } catch (e) {
      return Failure(EncryptionError('Failed to decrypt bytes', e.toString()));
    }
  }

  @override
  String deriveMasterKey(String password, String salt) {
    // Decode salt from base64
    final saltBytes = base64.decode(salt);

    // Use PBKDF2 with HMAC-SHA256
    final pbkdf2 = Pbkdf2(
      macAlgorithm: sha256,
      iterations: _pbkdf2Iterations,
      bits: _keyLength * 8, // 256 bits
    );

    // Derive key
    final derivedKey = pbkdf2.deriveKeyFromPassword(
      password: password,
      nonce: saltBytes,
    );

    // Return as hex string
    return derivedKey.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  @override
  String generateSalt() {
    // Generate 32 random bytes (256 bits)
    final bytes = List<int>.generate(
      _saltLength,
      (_) => _secureRandom.nextInt(256),
    );
    return base64.encode(bytes);
  }

  @override
  String generateIV() {
    // Generate 16 random bytes (128 bits)
    final bytes = List<int>.generate(
      _ivLength,
      (_) => _secureRandom.nextInt(256),
    );
    return base64.encode(bytes);
  }

  /// Converts hex string to bytes
  Uint8List _hexToBytes(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < hex.length; i += 2) {
      result[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return result;
  }
}

/// PBKDF2 implementation for key derivation
class Pbkdf2 {
  final Hash macAlgorithm;
  final int iterations;
  final int bits;

  Pbkdf2({
    required this.macAlgorithm,
    required this.iterations,
    required this.bits,
  });

  DerivedKey deriveKeyFromPassword({
    required String password,
    required List<int> nonce,
  }) {
    final passwordBytes = utf8.encode(password);
    final dkLen = (bits + 7) ~/ 8; // Convert bits to bytes
    final hLen = macAlgorithm.convert([]).bytes.length;
    final l = (dkLen + hLen - 1) ~/ hLen;

    final blocks = <List<int>>[];

    for (var i = 1; i <= l; i++) {
      blocks.add(_computeBlock(passwordBytes, nonce, i));
    }

    final dk = blocks.expand((block) => block).take(dkLen).toList();
    return DerivedKey(dk);
  }

  List<int> _computeBlock(List<int> password, List<int> salt, int blockNumber) {
    // U1 = PRF(password, salt || INT_32_BE(i))
    final blockBytes = [
      (blockNumber >> 24) & 0xff,
      (blockNumber >> 16) & 0xff,
      (blockNumber >> 8) & 0xff,
      blockNumber & 0xff,
    ];

    var u = Hmac(
      macAlgorithm,
      password,
    ).convert([...salt, ...blockBytes]).bytes;
    var result = List<int>.from(u);

    // U2 = PRF(password, U1), U3 = PRF(password, U2), ...
    for (var i = 1; i < iterations; i++) {
      u = Hmac(macAlgorithm, password).convert(u).bytes;
      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }

    return result;
  }
}

/// Represents a derived key
class DerivedKey {
  final List<int> bytes;

  DerivedKey(this.bytes);
}
