import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application theme configuration with light and dark mode support
/// Provides comprehensive color palettes, typography, and component themes
class AppTheme {
  // Prevent instantiation
  AppTheme._();

  // Color Palette - Light Mode
  static const Color _lightPrimary = Color(0xFF6366F1); // Indigo
  static const Color _lightSecondary = Color(0xFF8B5CF6); // Purple
  static const Color _lightAccent = Color(0xFF06B6D4); // Cyan
  static const Color _lightBackground = Color(0xFFF8FAFC);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color _lightError = Color(0xFFEF4444);
  static const Color _lightSuccess = Color(0xFF10B981);
  static const Color _lightWarning = Color(0xFFF59E0B);
  static const Color _lightInfo = Color(0xFF3B82F6);
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);
  static const Color _lightOnBackground = Color(0xFF1E293B);
  static const Color _lightOnSurface = Color(0xFF1E293B);
  static const Color _lightBorder = Color(0xFFE2E8F0);
  static const Color _lightDivider = Color(0xFFCBD5E1);

  // Color Palette - Dark Mode
  static const Color _darkPrimary = Color(0xFF818CF8); // Lighter Indigo
  static const Color _darkSecondary = Color(0xFFA78BFA); // Lighter Purple
  static const Color _darkAccent = Color(0xFF22D3EE); // Lighter Cyan
  static const Color _darkBackground = Color(0xFF0F172A);
  static const Color _darkSurface = Color(0xFF1E293B);
  static const Color _darkSurfaceVariant = Color(0xFF334155);
  static const Color _darkError = Color(0xFFF87171);
  static const Color _darkSuccess = Color(0xFF34D399);
  static const Color _darkWarning = Color(0xFFFBBF24);
  static const Color _darkInfo = Color(0xFF60A5FA);
  static const Color _darkOnPrimary = Color(0xFF0F172A);
  static const Color _darkOnBackground = Color(0xFFF1F5F9);
  static const Color _darkOnSurface = Color(0xFFF1F5F9);
  static const Color _darkBorder = Color(0xFF334155);
  static const Color _darkDivider = Color(0xFF475569);

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        secondary: _lightSecondary,
        tertiary: _lightAccent,
        surface: _lightSurface,
        surfaceContainerHighest: _lightSurfaceVariant,
        error: _lightError,
        onPrimary: _lightOnPrimary,
        onSecondary: _lightOnPrimary,
        onSurface: _lightOnSurface,
        onError: _lightOnPrimary,
        outline: _lightBorder,
      ),
      scaffoldBackgroundColor: _lightBackground,
      dividerColor: _lightDivider,
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _lightBackground,
        foregroundColor: _lightOnBackground,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _lightOnBackground,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: _lightSurface,
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: _lightBorder, width: 1.5),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightError, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: _lightPrimary,
        foregroundColor: _lightOnPrimary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _lightSurfaceVariant,
        selectedColor: _lightPrimary,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _lightOnPrimary;
          }
          return Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _lightPrimary;
          }
          return Colors.grey.shade300;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: _lightPrimary,
        inactiveTrackColor: _lightBorder,
        thumbColor: _lightPrimary,
        overlayColor: _lightPrimary.withValues(alpha: 0.2),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        secondary: _darkSecondary,
        tertiary: _darkAccent,
        surface: _darkSurface,
        surfaceContainerHighest: _darkSurfaceVariant,
        error: _darkError,
        onPrimary: _darkOnPrimary,
        onSecondary: _darkOnPrimary,
        onSurface: _darkOnSurface,
        onError: _darkOnPrimary,
        outline: _darkBorder,
      ),
      scaffoldBackgroundColor: _darkBackground,
      dividerColor: _darkDivider,
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _darkBackground,
        foregroundColor: _darkOnBackground,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _darkOnBackground,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: _darkSurface,
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: _darkBorder, width: 1.5),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkError, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: _darkPrimary,
        foregroundColor: _darkOnPrimary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _darkSurfaceVariant,
        selectedColor: _darkPrimary,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _darkOnPrimary;
          }
          return Colors.grey.shade600;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _darkPrimary;
          }
          return Colors.grey.shade700;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: _darkPrimary,
        inactiveTrackColor: _darkBorder,
        thumbColor: _darkPrimary,
        overlayColor: _darkPrimary.withValues(alpha: 0.2),
      ),
    );
  }

  /// Build text theme with Google Fonts
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.light
        ? _lightOnBackground
        : _darkOnBackground;

    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
    );
  }

  // Semantic color getters for light theme
  static Color get lightSuccess => _lightSuccess;
  static Color get lightWarning => _lightWarning;
  static Color get lightInfo => _lightInfo;
  static Color get lightError => _lightError;
  static Color get lightPrimary => _lightPrimary;
  static Color get lightSecondary => _lightSecondary;
  static Color get lightAccent => _lightAccent;
  static Color get lightSurface => _lightSurface;
  static Color get lightSurfaceVariant => _lightSurfaceVariant;
  static Color get lightBackground => _lightBackground;
  static Color get lightBorder => _lightBorder;
  static Color get lightDivider => _lightDivider;

  // Semantic color getters for dark theme
  static Color get darkSuccess => _darkSuccess;
  static Color get darkWarning => _darkWarning;
  static Color get darkInfo => _darkInfo;
  static Color get darkError => _darkError;
  static Color get darkPrimary => _darkPrimary;
  static Color get darkSecondary => _darkSecondary;
  static Color get darkAccent => _darkAccent;
  static Color get darkSurface => _darkSurface;
  static Color get darkSurfaceVariant => _darkSurfaceVariant;
  static Color get darkBackground => _darkBackground;
  static Color get darkBorder => _darkBorder;
  static Color get darkDivider => _darkDivider;

  /// Get semantic color based on current brightness
  static Color getSemanticColor(BuildContext context, SemanticColor color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (color) {
      case SemanticColor.success:
        return isDark ? _darkSuccess : _lightSuccess;
      case SemanticColor.warning:
        return isDark ? _darkWarning : _lightWarning;
      case SemanticColor.info:
        return isDark ? _darkInfo : _lightInfo;
      case SemanticColor.error:
        return isDark ? _darkError : _lightError;
      case SemanticColor.primary:
        return isDark ? _darkPrimary : _lightPrimary;
      case SemanticColor.secondary:
        return isDark ? _darkSecondary : _lightSecondary;
      case SemanticColor.accent:
        return isDark ? _darkAccent : _lightAccent;
    }
  }

  /// Get surface color based on current brightness
  static Color getSurfaceColor(BuildContext context, {bool variant = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (variant) {
      return isDark ? _darkSurfaceVariant : _lightSurfaceVariant;
    }
    return isDark ? _darkSurface : _lightSurface;
  }

  /// Get border color based on current brightness
  static Color getBorderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? _darkBorder : _lightBorder;
  }
}

/// Semantic color types for consistent theming
enum SemanticColor { success, warning, info, error, primary, secondary, accent }
