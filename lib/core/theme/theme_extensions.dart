import 'package:flutter/material.dart';

/// Extension on ThemeData for easy access to custom colors
extension ThemeDataExtensions on ThemeData {
  /// Get success color
  Color get successColor {
    return brightness == Brightness.dark
        ? const Color(0xFF34D399)
        : const Color(0xFF10B981);
  }

  /// Get warning color
  Color get warningColor {
    return brightness == Brightness.dark
        ? const Color(0xFFFBBF24)
        : const Color(0xFFF59E0B);
  }

  /// Get info color
  Color get infoColor {
    return brightness == Brightness.dark
        ? const Color(0xFF60A5FA)
        : const Color(0xFF3B82F6);
  }

  /// Get surface variant color
  Color get surfaceVariant {
    return brightness == Brightness.dark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);
  }

  /// Get border color
  Color get borderColor {
    return brightness == Brightness.dark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
  }

  /// Get divider color with proper opacity
  Color get dividerColorWithOpacity {
    return brightness == Brightness.dark
        ? const Color(0xFF475569)
        : const Color(0xFFCBD5E1);
  }
}

/// Extension on BuildContext for easy theme access
extension ThemeContextExtensions on BuildContext {
  /// Get current theme data
  ThemeData get theme => Theme.of(this);

  /// Get current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Check if current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Get success color
  Color get successColor => theme.successColor;

  /// Get warning color
  Color get warningColor => theme.warningColor;

  /// Get info color
  Color get infoColor => theme.infoColor;

  /// Get surface variant color
  Color get surfaceVariant => theme.surfaceVariant;

  /// Get border color
  Color get borderColor => theme.borderColor;
}
