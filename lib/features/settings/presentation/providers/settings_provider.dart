import 'package:flutter/material.dart';
import '../../../../core/services/auto_lock_service.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/result.dart';
import '../../domain/app_settings.dart';
import '../../domain/settings_repository.dart';

/// Provider for managing settings state
/// Integrates with ThemeProvider and AutoLockService for reactive updates
class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  final ThemeProvider? _themeProvider;
  final AutoLockService? _autoLockService;

  SettingsProvider({
    required SettingsRepository repository,
    ThemeProvider? themeProvider,
    AutoLockService? autoLockService,
  }) : _repository = repository,
       _themeProvider = themeProvider,
       _autoLockService = autoLockService {
    loadSettings();
  }

  AppSettings _settings = AppSettings.getDefaults();
  bool _isLoading = false;
  String? _errorMessage;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load settings from repository
  Future<void> loadSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.loadSettings();

    if (result.isSuccess) {
      _settings = result.valueOrNull ?? AppSettings.getDefaults();

      // Sync with theme provider
      _themeProvider?.initialize(_settings.themeMode);

      // Sync with auto-lock service
      _autoLockService?.setLockDuration(_settings.autoLockDuration);
    } else {
      _errorMessage = result.errorOrNull?.message ?? 'Failed to load settings';
      _settings = AppSettings.getDefaults();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update auto-lock duration
  Future<bool> updateAutoLockDuration(Duration duration) async {
    final updated = _settings.copyWith(autoLockDuration: duration);
    final success = await _saveSettings(updated);

    // Update auto-lock service immediately
    if (success) {
      _autoLockService?.setLockDuration(duration);
    }

    return success;
  }

  /// Update clipboard clear duration
  Future<bool> updateClipboardClearDuration(Duration duration) async {
    final updated = _settings.copyWith(clipboardClearDuration: duration);
    return await _saveSettings(updated);
  }

  /// Toggle biometrics
  Future<bool> toggleBiometrics(bool enabled) async {
    final updated = _settings.copyWith(biometricsEnabled: enabled);
    return await _saveSettings(updated);
  }

  /// Update theme mode
  Future<bool> updateThemeMode(ThemeMode mode) async {
    final updated = _settings.copyWith(themeMode: mode);
    final success = await _saveSettings(updated);

    // Update theme provider immediately
    if (success) {
      _themeProvider?.setThemeMode(mode);
    }

    return success;
  }

  /// Toggle breach check
  Future<bool> toggleBreachCheck(bool enabled) async {
    final updated = _settings.copyWith(breachCheckEnabled: enabled);
    return await _saveSettings(updated);
  }

  /// Change master password
  Future<bool> changeMasterPassword(
    String currentPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.changeMasterPassword(
      currentPassword,
      newPassword,
    );

    _isLoading = false;

    if (result.isSuccess) {
      notifyListeners();
      return true;
    } else {
      _errorMessage =
          result.errorOrNull?.message ?? 'Failed to change password';
      notifyListeners();
      return false;
    }
  }

  /// Change master PIN
  Future<bool> changeMasterPin(String currentPin, String newPin) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.changeMasterPin(currentPin, newPin);

    _isLoading = false;

    if (result.isSuccess) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorOrNull?.message ?? 'Failed to change PIN';
      notifyListeners();
      return false;
    }
  }

  /// Save settings to repository
  Future<bool> _saveSettings(AppSettings settings) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.saveSettings(settings);

    if (result.isSuccess) {
      _settings = settings;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorOrNull?.message ?? 'Failed to save settings';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
