import 'package:flutter/material.dart';

/// Domain entity representing application settings and preferences
class AppSettings {
  final Duration autoLockDuration;
  final Duration clipboardClearDuration;
  final bool biometricsEnabled;
  final ThemeMode themeMode;
  final bool breachCheckEnabled;

  const AppSettings({
    required this.autoLockDuration,
    required this.clipboardClearDuration,
    required this.biometricsEnabled,
    required this.themeMode,
    required this.breachCheckEnabled,
  });

  /// Returns default settings with secure values
  static AppSettings getDefaults() {
    return const AppSettings(
      autoLockDuration: Duration(minutes: 2),
      clipboardClearDuration: Duration(seconds: 30),
      biometricsEnabled: false,
      themeMode: ThemeMode.system,
      breachCheckEnabled: true,
    );
  }

  /// Creates a copy of this settings with the given fields replaced
  AppSettings copyWith({
    Duration? autoLockDuration,
    Duration? clipboardClearDuration,
    bool? biometricsEnabled,
    ThemeMode? themeMode,
    bool? breachCheckEnabled,
  }) {
    return AppSettings(
      autoLockDuration: autoLockDuration ?? this.autoLockDuration,
      clipboardClearDuration:
          clipboardClearDuration ?? this.clipboardClearDuration,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      themeMode: themeMode ?? this.themeMode,
      breachCheckEnabled: breachCheckEnabled ?? this.breachCheckEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppSettings &&
        other.autoLockDuration == autoLockDuration &&
        other.clipboardClearDuration == clipboardClearDuration &&
        other.biometricsEnabled == biometricsEnabled &&
        other.themeMode == themeMode &&
        other.breachCheckEnabled == breachCheckEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      autoLockDuration,
      clipboardClearDuration,
      biometricsEnabled,
      themeMode,
      breachCheckEnabled,
    );
  }
}
