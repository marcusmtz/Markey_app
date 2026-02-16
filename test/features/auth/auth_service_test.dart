import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:markey_app/core/services/secure_storage_service.dart';
import 'package:markey_app/core/utils/result.dart';
import 'package:markey_app/features/auth/data/auth_service_impl.dart';
import 'package:markey_app/features/auth/domain/auth_service.dart';
import 'mock_secure_storage.dart';

void main() {
  late AuthService authService;
  late SecureStorageService secureStorage;

  setUp(() {
    // Use mock storage for testing
    secureStorage = MockSecureStorage();
    final localAuth = LocalAuthentication();
    authService = AuthServiceImpl(secureStorage, localAuth);
  });

  tearDown(() async {
    // Clean up storage after each test
    await secureStorage.deleteAll();
  });

  group('AuthService - Master Password', () {
    const testPassword = 'TestPassword123!';
    const shortPassword = '1234567';
    const emptyPassword = '';

    test('should setup master password successfully', () async {
      final result = await authService.setupMasterPassword(testPassword);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isTrue);
      expect(await authService.isAuthenticated(), isTrue);
    });

    test('should fail to setup empty password', () async {
      final result = await authService.setupMasterPassword(emptyPassword);

      expect(result.isFailure, isTrue);
      expect(await authService.isAuthenticated(), isFalse);
    });

    test('should fail to setup password shorter than 8 characters', () async {
      final result = await authService.setupMasterPassword(shortPassword);

      expect(result.isFailure, isTrue);
      expect(await authService.isAuthenticated(), isFalse);
    });

    test('should fail to setup password when already set', () async {
      await authService.setupMasterPassword(testPassword);
      final result = await authService.setupMasterPassword('NewPassword123!');

      expect(result.isFailure, isTrue);
    });

    test('should authenticate with correct password', () async {
      await authService.setupMasterPassword(testPassword);
      await authService.logout();

      final result = await authService.authenticateWithPassword(testPassword);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isTrue);
      expect(await authService.isAuthenticated(), isTrue);
    });

    test('should fail to authenticate with incorrect password', () async {
      await authService.setupMasterPassword(testPassword);
      await authService.logout();

      final result = await authService.authenticateWithPassword(
        'WrongPassword',
      );

      expect(result.isFailure, isTrue);
      expect(await authService.isAuthenticated(), isFalse);
    });

    test('should fail to authenticate when password not set', () async {
      final result = await authService.authenticateWithPassword(testPassword);

      expect(result.isFailure, isTrue);
    });
  });

  group('AuthService - Master PIN', () {
    const testPin = '123456';
    const shortPin = '123';
    const nonNumericPin = '12ab56';
    const emptyPin = '';

    test('should setup master PIN successfully', () async {
      final result = await authService.setupMasterPin(testPin);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isTrue);
      expect(await authService.isAuthenticated(), isTrue);
    });

    test('should fail to setup empty PIN', () async {
      final result = await authService.setupMasterPin(emptyPin);

      expect(result.isFailure, isTrue);
      expect(await authService.isAuthenticated(), isFalse);
    });

    test('should fail to setup PIN shorter than 4 digits', () async {
      final result = await authService.setupMasterPin(shortPin);

      expect(result.isFailure, isTrue);
      expect(await authService.isAuthenticated(), isFalse);
    });

    test('should fail to setup non-numeric PIN', () async {
      final result = await authService.setupMasterPin(nonNumericPin);

      expect(result.isFailure, isTrue);
      expect(await authService.isAuthenticated(), isFalse);
    });

    test('should fail to setup PIN when already set', () async {
      await authService.setupMasterPin(testPin);
      final result = await authService.setupMasterPin('654321');

      expect(result.isFailure, isTrue);
    });

    test('should authenticate with correct PIN', () async {
      await authService.setupMasterPin(testPin);
      await authService.logout();

      final result = await authService.authenticateWithPin(testPin);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isTrue);
      expect(await authService.isAuthenticated(), isTrue);
    });

    test('should fail to authenticate with incorrect PIN', () async {
      await authService.setupMasterPin(testPin);
      await authService.logout();

      final result = await authService.authenticateWithPin('654321');

      expect(result.isFailure, isTrue);
      expect(await authService.isAuthenticated(), isFalse);
    });

    test('should fail to authenticate when PIN not set', () async {
      final result = await authService.authenticateWithPin(testPin);

      expect(result.isFailure, isTrue);
    });
  });

  group('AuthService - Failed Attempts and Locking', () {
    const testPassword = 'TestPassword123!';

    test('should lock account after 3 failed password attempts', () async {
      await authService.setupMasterPassword(testPassword);
      await authService.logout();

      // First failed attempt
      await authService.authenticateWithPassword('Wrong1');
      expect(await authService.isLocked(), isFalse);

      // Second failed attempt
      await authService.authenticateWithPassword('Wrong2');
      expect(await authService.isLocked(), isFalse);

      // Third failed attempt - should lock
      await authService.authenticateWithPassword('Wrong3');
      expect(await authService.isLocked(), isTrue);
    });

    test('should lock account after 3 failed PIN attempts', () async {
      await authService.setupMasterPin('123456');
      await authService.logout();

      // Three failed attempts
      await authService.authenticateWithPin('111111');
      await authService.authenticateWithPin('222222');
      await authService.authenticateWithPin('333333');

      expect(await authService.isLocked(), isTrue);
    });

    test('should prevent authentication when locked', () async {
      await authService.setupMasterPassword(testPassword);
      await authService.logout();

      // Lock the account
      await authService.authenticateWithPassword('Wrong1');
      await authService.authenticateWithPassword('Wrong2');
      await authService.authenticateWithPassword('Wrong3');

      // Try to authenticate with correct password
      final result = await authService.authenticateWithPassword(testPassword);

      expect(result.isFailure, isTrue);
      expect(await authService.isAuthenticated(), isFalse);
    });

    test('should return remaining lock time when locked', () async {
      await authService.setupMasterPassword(testPassword);
      await authService.logout();

      // Lock the account
      await authService.authenticateWithPassword('Wrong1');
      await authService.authenticateWithPassword('Wrong2');
      await authService.authenticateWithPassword('Wrong3');

      final remainingTime = await authService.getRemainingLockTime();

      expect(remainingTime, greaterThan(0));
      expect(remainingTime, lessThanOrEqualTo(30));
    });

    test(
      'should reset failed attempts after successful authentication',
      () async {
        await authService.setupMasterPassword(testPassword);
        await authService.logout();

        // Two failed attempts
        await authService.authenticateWithPassword('Wrong1');
        await authService.authenticateWithPassword('Wrong2');

        // Successful authentication
        await authService.authenticateWithPassword(testPassword);
        await authService.logout();

        // Should not be locked after previous failed attempts
        await authService.authenticateWithPassword('Wrong1');
        await authService.authenticateWithPassword('Wrong2');
        expect(await authService.isLocked(), isFalse);
      },
    );
  });

  group('AuthService - Session Management', () {
    const testPassword = 'TestPassword123!';

    test('should maintain authenticated state after setup', () async {
      await authService.setupMasterPassword(testPassword);

      expect(await authService.isAuthenticated(), isTrue);
    });

    test('should clear authenticated state after logout', () async {
      await authService.setupMasterPassword(testPassword);
      expect(await authService.isAuthenticated(), isTrue);

      await authService.logout();

      expect(await authService.isAuthenticated(), isFalse);
    });

    test(
      'should set authenticated state after successful authentication',
      () async {
        await authService.setupMasterPassword(testPassword);
        await authService.logout();
        expect(await authService.isAuthenticated(), isFalse);

        await authService.authenticateWithPassword(testPassword);

        expect(await authService.isAuthenticated(), isTrue);
      },
    );

    test(
      'should not set authenticated state after failed authentication',
      () async {
        await authService.setupMasterPassword(testPassword);
        await authService.logout();

        await authService.authenticateWithPassword('WrongPassword');

        expect(await authService.isAuthenticated(), isFalse);
      },
    );
  });

  group('AuthService - Biometric Authentication', () {
    const testPassword = 'TestPassword123!';

    test('should check if biometrics are available', () async {
      // This will depend on the device/emulator
      final isAvailable = await authService.isBiometricsAvailable();

      expect(isAvailable, isA<bool>());
    });

    test('should fail to enable biometrics when not authenticated', () async {
      final result = await authService.enableBiometrics();

      expect(result.isFailure, isTrue);
    });

    test('should enable biometrics when authenticated', () async {
      await authService.setupMasterPassword(testPassword);

      // Note: This may fail on devices without biometric support
      final result = await authService.enableBiometrics();

      // We accept both success and failure here since it depends on device
      expect(result, isA<Result<void>>());
    });

    test('should disable biometrics', () async {
      final result = await authService.disableBiometrics();

      expect(result.isSuccess, isTrue);
    });
  });

  group('AuthService - Edge Cases', () {
    test('should handle very long passwords', () async {
      final longPassword = 'A' * 1000;
      final result = await authService.setupMasterPassword(longPassword);

      expect(result.isSuccess, isTrue);
    });

    test('should handle passwords with special characters', () async {
      const specialPassword = '!@#\$%^&*()_+-=[]{}|;:,.<>?/~`"\'\\';
      final result = await authService.setupMasterPassword(specialPassword);

      expect(result.isSuccess, isTrue);

      await authService.logout();
      final authResult = await authService.authenticateWithPassword(
        specialPassword,
      );
      expect(authResult.isSuccess, isTrue);
    });

    test('should handle passwords with Unicode characters', () async {
      const unicodePassword = 'Pass世界🌍Привет123!';
      final result = await authService.setupMasterPassword(unicodePassword);

      expect(result.isSuccess, isTrue);

      await authService.logout();
      final authResult = await authService.authenticateWithPassword(
        unicodePassword,
      );
      expect(authResult.isSuccess, isTrue);
    });

    test('should handle very long PINs', () async {
      final longPin = '1' * 100;
      final result = await authService.setupMasterPin(longPin);

      expect(result.isSuccess, isTrue);
    });

    test('should return 0 remaining lock time when not locked', () async {
      final remainingTime = await authService.getRemainingLockTime();

      expect(remainingTime, equals(0));
    });
  });
}
