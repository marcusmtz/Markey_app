import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:markey_app/core/services/encryption_service.dart';
import 'package:markey_app/core/services/encryption_service_impl.dart';
import 'package:markey_app/core/utils/result.dart';

void main() {
  late EncryptionService encryptionService;

  setUp(() {
    encryptionService = EncryptionServiceImpl();
  });

  group('EncryptionService', () {
    const testPassword = 'TestMasterPassword123!';
    const testPlaintext = 'Hello, World!';

    test('should generate unique salts', () {
      final salt1 = encryptionService.generateSalt();
      final salt2 = encryptionService.generateSalt();

      expect(salt1, isNotEmpty);
      expect(salt2, isNotEmpty);
      expect(salt1, isNot(equals(salt2)));
    });

    test('should generate unique IVs', () {
      final iv1 = encryptionService.generateIV();
      final iv2 = encryptionService.generateIV();

      expect(iv1, isNotEmpty);
      expect(iv2, isNotEmpty);
      expect(iv1, isNot(equals(iv2)));
    });

    test('should derive consistent master key from same password and salt', () {
      final salt = encryptionService.generateSalt();
      final key1 = encryptionService.deriveMasterKey(testPassword, salt);
      final key2 = encryptionService.deriveMasterKey(testPassword, salt);

      expect(key1, equals(key2));
      expect(key1, isNotEmpty);
    });

    test('should derive different keys for different salts', () {
      final salt1 = encryptionService.generateSalt();
      final salt2 = encryptionService.generateSalt();
      final key1 = encryptionService.deriveMasterKey(testPassword, salt1);
      final key2 = encryptionService.deriveMasterKey(testPassword, salt2);

      expect(key1, isNot(equals(key2)));
    });

    test('should encrypt and decrypt string successfully', () async {
      final encryptResult = await encryptionService.encrypt(
        testPlaintext,
        testPassword,
      );

      expect(encryptResult.isSuccess, isTrue);
      final encrypted = encryptResult.valueOrNull!;
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(equals(testPlaintext)));

      // Verify format: salt:iv:ciphertext
      final parts = encrypted.split(':');
      expect(parts.length, equals(3));

      final decryptResult = await encryptionService.decrypt(
        encrypted,
        testPassword,
      );

      expect(decryptResult.isSuccess, isTrue);
      final decrypted = decryptResult.valueOrNull!;
      expect(decrypted, equals(testPlaintext));
    });

    test('should fail to decrypt with wrong password', () async {
      final encryptResult = await encryptionService.encrypt(
        testPlaintext,
        testPassword,
      );

      expect(encryptResult.isSuccess, isTrue);
      final encrypted = encryptResult.valueOrNull!;

      final decryptResult = await encryptionService.decrypt(
        encrypted,
        'WrongPassword',
      );

      expect(decryptResult.isFailure, isTrue);
    });

    test('should encrypt empty string', () async {
      final encryptResult = await encryptionService.encrypt('', testPassword);

      expect(encryptResult.isSuccess, isTrue);
      final encrypted = encryptResult.valueOrNull!;

      final decryptResult = await encryptionService.decrypt(
        encrypted,
        testPassword,
      );

      expect(decryptResult.isSuccess, isTrue);
      expect(decryptResult.valueOrNull, equals(''));
    });

    test('should encrypt string with special characters', () async {
      const specialText = '!@#\$%^&*()_+-=[]{}|;:,.<>?/~`"\'\\';
      final encryptResult = await encryptionService.encrypt(
        specialText,
        testPassword,
      );

      expect(encryptResult.isSuccess, isTrue);
      final encrypted = encryptResult.valueOrNull!;

      final decryptResult = await encryptionService.decrypt(
        encrypted,
        testPassword,
      );

      expect(decryptResult.isSuccess, isTrue);
      expect(decryptResult.valueOrNull, equals(specialText));
    });

    test('should encrypt string with Unicode characters', () async {
      const unicodeText = 'Hello 世界 🌍 Привет مرحبا';
      final encryptResult = await encryptionService.encrypt(
        unicodeText,
        testPassword,
      );

      expect(encryptResult.isSuccess, isTrue);
      final encrypted = encryptResult.valueOrNull!;

      final decryptResult = await encryptionService.decrypt(
        encrypted,
        testPassword,
      );

      expect(decryptResult.isSuccess, isTrue);
      expect(decryptResult.valueOrNull, equals(unicodeText));
    });

    test('should fail to decrypt invalid format', () async {
      final decryptResult = await encryptionService.decrypt(
        'invalid:format',
        testPassword,
      );

      expect(decryptResult.isFailure, isTrue);
    });

    test('should encrypt and decrypt bytes successfully', () async {
      final testBytes = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

      final encryptResult = await encryptionService.encryptBytes(
        testBytes,
        testPassword,
      );

      expect(encryptResult.isSuccess, isTrue);
      final encrypted = encryptResult.valueOrNull!;
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(equals(testBytes)));

      final decryptResult = await encryptionService.decryptBytes(
        encrypted,
        testPassword,
      );

      expect(decryptResult.isSuccess, isTrue);
      final decrypted = decryptResult.valueOrNull!;
      expect(decrypted, equals(testBytes));
    });

    test('should fail to decrypt bytes with wrong password', () async {
      final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      final encryptResult = await encryptionService.encryptBytes(
        testBytes,
        testPassword,
      );

      expect(encryptResult.isSuccess, isTrue);
      final encrypted = encryptResult.valueOrNull!;

      final decryptResult = await encryptionService.decryptBytes(
        encrypted,
        'WrongPassword',
      );

      expect(decryptResult.isFailure, isTrue);
    });

    test('should fail to decrypt bytes that are too short', () async {
      final tooShort = Uint8List.fromList([1, 2, 3]);

      final decryptResult = await encryptionService.decryptBytes(
        tooShort,
        testPassword,
      );

      expect(decryptResult.isFailure, isTrue);
    });

    test('should produce different ciphertexts for same plaintext', () async {
      final encrypt1 = await encryptionService.encrypt(
        testPlaintext,
        testPassword,
      );
      final encrypt2 = await encryptionService.encrypt(
        testPlaintext,
        testPassword,
      );

      expect(encrypt1.isSuccess, isTrue);
      expect(encrypt2.isSuccess, isTrue);

      // Different IVs should produce different ciphertexts
      expect(encrypt1.valueOrNull, isNot(equals(encrypt2.valueOrNull)));

      // But both should decrypt to the same plaintext
      final decrypt1 = await encryptionService.decrypt(
        encrypt1.valueOrNull!,
        testPassword,
      );
      final decrypt2 = await encryptionService.decrypt(
        encrypt2.valueOrNull!,
        testPassword,
      );

      expect(decrypt1.valueOrNull, equals(testPlaintext));
      expect(decrypt2.valueOrNull, equals(testPlaintext));
    });
  });
}
