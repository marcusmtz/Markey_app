import 'package:flutter/material.dart';
import 'theme_provider.dart';
import 'theme_service.dart';
import 'app_theme.dart';

/// Implementation of ThemeService
/// Delegates to ThemeProvider for state management
class ThemeServiceImpl implements ThemeService {
  final ThemeProvider _themeProvider;

  ThemeServiceImpl(this._themeProvider);

  @override
  ThemeMode getCurrentTheme() {
    return _themeProvider.themeMode;
  }

  @override
  Future<void> setTheme(ThemeMode mode) async {
    _themeProvider.setThemeMode(mode);
  }

  @override
  ThemeData getLightTheme() {
    return AppTheme.lightTheme;
  }

  @override
  ThemeData getDarkTheme() {
    return AppTheme.darkTheme;
  }

  @override
  bool isDarkMode(BuildContext context) {
    return _themeProvider.isDarkMode(context);
  }

  @override
  Future<void> toggleTheme() async {
    _themeProvider.toggleTheme();
  }
}
