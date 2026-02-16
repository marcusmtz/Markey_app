import 'package:flutter/material.dart';

/// Provider for managing theme state
/// Handles theme mode changes and persists user preference
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  /// Initialize theme from settings
  /// Should be called once when loading settings
  void initialize(ThemeMode mode) {
    _themeMode = mode;
    _isInitialized = true;
    notifyListeners();
  }

  /// Set theme mode
  /// Notifies listeners to trigger UI rebuild
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  /// Toggle between light and dark mode
  /// If currently in system mode, defaults to light
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      // If system, default to light
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  /// Check if current theme is dark
  /// Takes into account system theme when in system mode
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Get theme mode display name
  String getThemeModeName() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }
}
