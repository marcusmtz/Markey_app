import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markey_app/core/services/encryption_service_impl.dart';
import 'package:markey_app/core/utils/result.dart';
import 'package:markey_app/features/auth/data/auth_service_impl.dart';
import 'package:markey_app/features/settings/data/settings_repository_impl.dart';
import 'package:markey_app/features/settings/domain/app_settings.dart';
import 'package:markey_app/features/settings/domain/settings_repository.dart';
import 'package:local_auth/local_auth.dart';
import '../../../features/auth/mock_secure_storage.dart';

void main() {
  late SettingsRepository repository;
  late MockSecureStorage storage;
  late EncryptionServiceImpl encryptionService;
  late AuthServiceImpl authService;
  late LocalAuthentication localAuth;

  setUp(() {
    storage = MockSecureStorage();
    encryptionService = EncryptionServiceImpl();
    localAuth = LocalAuthentication();
    authService = AuthServiceImpl(storage, localAuth);
    repository = SettingsRepositoryImpl(
      storage,
      encryptionService,
      authService,
    );
  });

  // Helper functions to check Result types
  bool isSuccess<T>(Result<T> result) => result is Success<T>;
  bool isFailure<T>(Result<T> result) => result is Failure<T>;
  T? getValue<T>(Result<T> result) =>
      result is Success<T> ? result.value : null;

  group('SettingsRepository - Save and Load', () {
    test('should save and load settings', () async {
      final settings = AppSettings(
        autoLockDuration: const Duration(minutes: 5),
        clipboardClearDuration: const Duration(seconds: 45),
        biometricsEnabled: true,
        themeMode: ThemeMode.dark,
        breachCheckEnabled: false,
      );

      final saveResult = await repository.saveSettings(settings);
      expect(isSuccess(saveResult), isTrue);

      final loadResult = await repository.loadSettings();
      expect(isSuccess(loadResult), isTrue);

      final loaded = getValue(loadResult)!;
      expect(loaded.autoLockDuration, equals(const Duration(minutes: 5)));
      expect(
        loaded.clipboardClearDuration,
        equals(const Duration(seconds: 45)),
      );
      expect(loaded.biometricsEnabled, isTrue);
      expect(loaded.themeMode, equals(ThemeMode.dark));
      expect(loaded.breachCheckEnabled, isFalse);
    });

    test('should return defaults when no settings exist', () async {
      final result = await repository.loadSettings();

      expect(isSuccess(result), isTrue);
      final settings = getValue(result)!;
      expect(settings.autoLockDuration, equals(const Duration(minutes: 2)));
      expect(
        settings.clipboardClearDuration,
        equals(const Duration(seconds: 30)),
      );
      expect(settings.biometricsEnabled, isFalse);
      expect(settings.themeMode, equals(ThemeMode.system));
      expect(settings.breachCheckEnabled, isTrue);
    });

    test('should get defaults', () {
      final defaults = repository.getDefaults();

      expect(defaults.autoLockDuration, equals(const Duration(minutes: 2)));
      expect(
        defaults.clipboardClearDuration,
        equals(const Duration(seconds: 30)),
      );
      expect(defaults.biometricsEnabled, isFalse);
      expect(defaults.themeMode, equals(ThemeMode.system));
      expect(defaults.breachCheckEnabled, isTrue);
    });
  });

  group('SettingsRepository - Change Master Password', () {
    test(
      'should change master password with correct current password',
      () async {
        // Setup initial password
        await authService.setupMasterPassword('OldPassword123!');

        // Change password
        final result = await repository.changeMasterPassword(
          'OldPassword123!',
          'NewPassword456!',
        );

        expect(isSuccess(result), isTrue);

        // Verify new password works
        final authResult = await authService.authenticateWithPassword(
          'NewPassword456!',
        );
        expect(isSuccess(authResult), isTrue);
      },
    );

    test(
      'should fail to change password with incorrect current password',
      () async {
        // Setup initial password
        await authService.setupMasterPassword('OldPassword123!');

        // Try to change with wrong current password
        final result = await repository.changeMasterPassword(
          'WrongPassword!',
          'NewPassword456!',
        );

        expect(isFailure(result), isTrue);
      },
    );

    test('should fail to change password when not authenticated', () async {
      final result = await repository.changeMasterPassword(
        'OldPassword123!',
        'NewPassword456!',
      );

      expect(isFailure(result), isTrue);
    });

    test('should fail with empty new password', () async {
      // Setup and authenticate
      await authService.setupMasterPassword('OldPassword123!');

      final result = await repository.changeMasterPassword(
        'OldPassword123!',
        '',
      );

      expect(isFailure(result), isTrue);
    });

    test('should fail with short new password', () async {
      // Setup and authenticate
      await authService.setupMasterPassword('OldPassword123!');

      final result = await repository.changeMasterPassword(
        'OldPassword123!',
        'short',
      );

      expect(isFailure(result), isTrue);
    });

    test('should fail when new password is same as current', () async {
      // Setup and authenticate
      await authService.setupMasterPassword('OldPassword123!');

      final result = await repository.changeMasterPassword(
        'OldPassword123!',
        'OldPassword123!',
      );

      expect(isFailure(result), isTrue);
    });
  });

  group('SettingsRepository - Change Master PIN', () {
    test('should change master PIN with correct current PIN', () async {
      // Setup initial PIN
      await authService.setupMasterPin('1234');

      // Change PIN
      final result = await repository.changeMasterPin('1234', '5678');

      expect(isSuccess(result), isTrue);

      // Verify new PIN works
      final authResult = await authService.authenticateWithPin('5678');
      expect(isSuccess(authResult), isTrue);
    });

    test('should fail to change PIN with incorrect current PIN', () async {
      // Setup initial PIN
      await authService.setupMasterPin('1234');

      // Try to change with wrong current PIN
      final result = await repository.changeMasterPin('9999', '5678');

      expect(isFailure(result), isTrue);
    });

    test('should fail to change PIN when not authenticated', () async {
      final result = await repository.changeMasterPin('1234', '5678');

      expect(isFailure(result), isTrue);
    });

    test('should fail with empty new PIN', () async {
      // Setup and authenticate
      await authService.setupMasterPin('1234');

      final result = await repository.changeMasterPin('1234', '');

      expect(isFailure(result), isTrue);
    });

    test('should fail with non-numeric new PIN', () async {
      // Setup and authenticate
      await authService.setupMasterPin('1234');

      final result = await repository.changeMasterPin('1234', 'abcd');

      expect(isFailure(result), isTrue);
    });

    test('should fail with short new PIN', () async {
      // Setup and authenticate
      await authService.setupMasterPin('1234');

      final result = await repository.changeMasterPin('1234', '12');

      expect(isFailure(result), isTrue);
    });

    test('should fail when new PIN is same as current', () async {
      // Setup and authenticate
      await authService.setupMasterPin('1234');

      final result = await repository.changeMasterPin('1234', '1234');

      expect(isFailure(result), isTrue);
    });
  });
}
