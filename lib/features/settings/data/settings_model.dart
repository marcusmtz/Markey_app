import 'package:flutter/material.dart';
import '../domain/app_settings.dart';

/// Data model for AppSettings with JSON serialization
class SettingsModel {
  final int autoLockDurationSeconds;
  final int clipboardClearDurationSeconds;
  final bool biometricsEnabled;
  final String themeMode;
  final bool breachCheckEnabled;

  const SettingsModel({
    required this.autoLockDurationSeconds,
    required this.clipboardClearDurationSeconds,
    required this.biometricsEnabled,
    required this.themeMode,
    required this.breachCheckEnabled,
  });

  /// Converts this model to JSON
  Map<String, dynamic> toJson() {
    return {
      'autoLockDurationSeconds': autoLockDurationSeconds,
      'clipboardClearDurationSeconds': clipboardClearDurationSeconds,
      'biometricsEnabled': biometricsEnabled,
      'themeMode': themeMode,
      'breachCheckEnabled': breachCheckEnabled,
    };
  }

  /// Creates a model from JSON
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      autoLockDurationSeconds: json['autoLockDurationSeconds'] as int,
      clipboardClearDurationSeconds:
          json['clipboardClearDurationSeconds'] as int,
      biometricsEnabled: json['biometricsEnabled'] as bool,
      themeMode: json['themeMode'] as String,
      breachCheckEnabled: json['breachCheckEnabled'] as bool,
    );
  }

  /// Converts domain AppSettings to SettingsModel
  factory SettingsModel.fromDomain(AppSettings settings) {
    return SettingsModel(
      autoLockDurationSeconds: settings.autoLockDuration.inSeconds,
      clipboardClearDurationSeconds: settings.clipboardClearDuration.inSeconds,
      biometricsEnabled: settings.biometricsEnabled,
      themeMode: _themeModeToString(settings.themeMode),
      breachCheckEnabled: settings.breachCheckEnabled,
    );
  }

  /// Converts this model to domain AppSettings
  AppSettings toDomain() {
    return AppSettings(
      autoLockDuration: Duration(seconds: autoLockDurationSeconds),
      clipboardClearDuration: Duration(seconds: clipboardClearDurationSeconds),
      biometricsEnabled: biometricsEnabled,
      themeMode: _stringToThemeMode(themeMode),
      breachCheckEnabled: breachCheckEnabled,
    );
  }

  /// Converts ThemeMode to string
  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Converts string to ThemeMode
  static ThemeMode _stringToThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
