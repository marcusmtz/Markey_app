import 'dart:convert';
import '../../../core/errors/failures.dart';
import '../../../core/services/encryption_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/utils/result.dart';
import '../../auth/domain/auth_service.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';
import 'settings_model.dart';

/// Implementation of SettingsRepository
/// Persists settings in encrypted format using SecureStorageService
class SettingsRepositoryImpl implements SettingsRepository {
  final SecureStorageService _secureStorage;
  final EncryptionService _encryptionService;
  final AuthService _authService;

  // Storage keys
  static const String _settingsKey = 'app_settings';
  static const String _masterPasswordHashKey = 'master_password_hash';
  static const String _masterPinHashKey = 'master_pin_hash';
  static const String _encryptionSaltKey = 'encryption_salt';

  SettingsRepositoryImpl(
    this._secureStorage,
    this._encryptionService,
    this._authService,
  );

  @override
  Future<Result<void>> saveSettings(AppSettings settings) async {
    try {
      // Convert to model
      final model = SettingsModel.fromDomain(settings);

      // Convert to JSON
      final jsonString = jsonEncode(model.toJson());

      // Get or create encryption salt
      final saltResult = await _getOrCreateEncryptionSalt();
      if (saltResult.isFailure) {
        return Failure(saltResult.errorOrNull!);
      }
      final salt = saltResult.valueOrNull!;

      // Derive a key for settings encryption (using a fixed password for settings)
      // In production, this could use the master password, but for settings
      // we use a derived key to allow settings to be loaded before authentication
      final masterKey = _encryptionService.deriveMasterKey(
        'settings_key',
        salt,
      );

      // Encrypt the JSON
      final encryptResult = await _encryptionService.encrypt(
        jsonString,
        masterKey,
      );
      if (encryptResult.isFailure) {
        return Failure(encryptResult.errorOrNull!);
      }

      // Store encrypted settings
      final storeResult = await _secureStorage.write(
        _settingsKey,
        encryptResult.valueOrNull!,
      );

      if (storeResult.isFailure) {
        return Failure(storeResult.errorOrNull!);
      }

      return const Success(null);
    } catch (e) {
      return Failure(StorageError('Failed to save settings', e.toString()));
    }
  }

  @override
  Future<Result<AppSettings>> loadSettings() async {
    try {
      // Try to read encrypted settings
      final readResult = await _secureStorage.read(_settingsKey);
      if (readResult.isFailure) {
        return Failure(readResult.errorOrNull!);
      }

      final encryptedData = readResult.valueOrNull;

      // If no settings exist, return defaults
      if (encryptedData == null || encryptedData.isEmpty) {
        return Success(getDefaults());
      }

      // Get encryption salt
      final saltResult = await _secureStorage.read(_encryptionSaltKey);
      if (saltResult.isFailure || saltResult.valueOrNull == null) {
        // If salt is missing but settings exist, return defaults
        return Success(getDefaults());
      }
      final salt = saltResult.valueOrNull!;

      // Derive the key
      final masterKey = _encryptionService.deriveMasterKey(
        'settings_key',
        salt,
      );

      // Decrypt the data
      final decryptResult = await _encryptionService.decrypt(
        encryptedData,
        masterKey,
      );
      if (decryptResult.isFailure) {
        // If decryption fails, return defaults
        return Success(getDefaults());
      }

      // Parse JSON
      final jsonData = jsonDecode(decryptResult.valueOrNull!);
      final model = SettingsModel.fromJson(jsonData as Map<String, dynamic>);

      return Success(model.toDomain());
    } catch (e) {
      // On any error, return defaults to ensure app can function
      return Success(getDefaults());
    }
  }

  @override
  AppSettings getDefaults() {
    return AppSettings.getDefaults();
  }

  @override
  Future<Result<void>> changeMasterPassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      // Verify user is authenticated
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated) {
        return Failure(
          AuthenticationError('Must be authenticated to change password'),
        );
      }

      // Authenticate with current password to verify
      final authResult = await _authService.authenticateWithPassword(
        currentPassword,
      );
      if (authResult.isFailure) {
        return Failure(
          AuthenticationError(
            'Current password is incorrect',
            'Please verify your current password',
          ),
        );
      }

      // Validate new password
      if (newPassword.isEmpty) {
        return Failure(
          ValidationError('New password cannot be empty', {
            'newPassword': 'required',
          }),
        );
      }

      if (newPassword.length < 8) {
        return Failure(
          ValidationError('New password too short', {
            'newPassword': 'must be at least 8 characters',
          }),
        );
      }

      if (newPassword == currentPassword) {
        return Failure(
          ValidationError('New password must be different', {
            'newPassword': 'cannot be the same as current password',
          }),
        );
      }

      // Delete old password hash
      final deleteResult = await _secureStorage.delete(_masterPasswordHashKey);
      if (deleteResult.isFailure) {
        return Failure(deleteResult.errorOrNull!);
      }

      // Setup new password using AuthService
      // First logout to allow setup
      await _authService.logout();
      final setupResult = await _authService.setupMasterPassword(newPassword);
      if (setupResult.isFailure) {
        return Failure(setupResult.errorOrNull!);
      }

      return const Success(null);
    } catch (e) {
      return Failure(
        AuthenticationError('Failed to change master password', e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> changeMasterPin(String currentPin, String newPin) async {
    try {
      // Verify user is authenticated
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated) {
        return Failure(
          AuthenticationError('Must be authenticated to change PIN'),
        );
      }

      // Authenticate with current PIN to verify
      final authResult = await _authService.authenticateWithPin(currentPin);
      if (authResult.isFailure) {
        return Failure(
          AuthenticationError(
            'Current PIN is incorrect',
            'Please verify your current PIN',
          ),
        );
      }

      // Validate new PIN
      if (newPin.isEmpty) {
        return Failure(
          ValidationError('New PIN cannot be empty', {'newPin': 'required'}),
        );
      }

      if (!RegExp(r'^\d+$').hasMatch(newPin)) {
        return Failure(
          ValidationError('PIN must contain only digits', {
            'newPin': 'must be numeric',
          }),
        );
      }

      if (newPin.length < 4) {
        return Failure(
          ValidationError('New PIN too short', {
            'newPin': 'must be at least 4 digits',
          }),
        );
      }

      if (newPin == currentPin) {
        return Failure(
          ValidationError('New PIN must be different', {
            'newPin': 'cannot be the same as current PIN',
          }),
        );
      }

      // Delete old PIN hash
      final deleteResult = await _secureStorage.delete(_masterPinHashKey);
      if (deleteResult.isFailure) {
        return Failure(deleteResult.errorOrNull!);
      }

      // Setup new PIN using AuthService
      // First logout to allow setup
      await _authService.logout();
      final setupResult = await _authService.setupMasterPin(newPin);
      if (setupResult.isFailure) {
        return Failure(setupResult.errorOrNull!);
      }

      return const Success(null);
    } catch (e) {
      return Failure(
        AuthenticationError('Failed to change master PIN', e.toString()),
      );
    }
  }

  /// Gets or creates the encryption salt for settings
  Future<Result<String>> _getOrCreateEncryptionSalt() async {
    // Try to read existing salt
    final saltResult = await _secureStorage.read(_encryptionSaltKey);
    if (saltResult.isSuccess && saltResult.valueOrNull != null) {
      return Success(saltResult.valueOrNull!);
    }

    // Generate new salt
    final newSalt = _encryptionService.generateSalt();

    // Store the salt
    final storeResult = await _secureStorage.write(_encryptionSaltKey, newSalt);
    if (storeResult.isFailure) {
      return Failure(storeResult.errorOrNull!);
    }

    return Success(newSalt);
  }
}
