import '../../../core/utils/result.dart';
import 'app_settings.dart';

/// Abstract interface for settings persistence operations
abstract class SettingsRepository {
  /// Saves settings to encrypted storage
  /// [settings] - The settings to persist
  Future<Result<void>> saveSettings(AppSettings settings);

  /// Loads settings from encrypted storage
  /// Returns default settings if none exist
  Future<Result<AppSettings>> loadSettings();

  /// Returns default settings with secure values
  AppSettings getDefaults();

  /// Changes the master password
  /// [currentPassword] - The current master password for verification
  /// [newPassword] - The new master password to set
  /// Requires authentication with current password before changing
  Future<Result<void>> changeMasterPassword(
    String currentPassword,
    String newPassword,
  );

  /// Changes the master PIN
  /// [currentPin] - The current master PIN for verification
  /// [newPin] - The new master PIN to set
  /// Requires authentication with current PIN before changing
  Future<Result<void>> changeMasterPin(String currentPin, String newPin);
}
