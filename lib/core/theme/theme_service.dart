import 'package:flutter/material.dart';

/// Abstract interface for theme management
/// Handles theme mode changes and persistence
abstract class ThemeService {
  /// Get the current theme mode
  ThemeMode getCurrentTheme();

  /// Set the theme mode
  /// [mode] - The theme mode to set (light, dark, or system)
  Future<void> setTheme(ThemeMode mode);

  /// Get the light theme data
  ThemeData getLightTheme();

  /// Get the dark theme data
  ThemeData getDarkTheme();

  /// Check if the current theme is dark mode
  /// [context] - Build context to check platform brightness for system mode
  bool isDarkMode(BuildContext context);

  /// Toggle between light and dark mode
  /// If currently in system mode, defaults to light
  Future<void> toggleTheme();
}
