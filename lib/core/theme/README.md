# Markey Theme System

Complete theme system with color palettes, typography, glassmorphism components, and reactive theme switching.

## Features

- ✅ Comprehensive color palettes for light and dark modes
- ✅ Google Fonts integration (Inter font family)
- ✅ Reusable glassmorphism components
- ✅ Reactive theme switching
- ✅ Theme persistence via SettingsRepository
- ✅ Semantic color system
- ✅ Theme constants for consistent spacing and sizing
- ✅ Theme extensions for easy access

## Usage

### Basic Theme Access

```dart
import 'package:markey_app/core/theme/theme.dart';

// In your widget
@override
Widget build(BuildContext context) {
  // Access theme
  final theme = context.theme;
  final colorScheme = context.colorScheme;
  final textTheme = context.textTheme;
  
  // Check if dark mode
  final isDark = context.isDarkMode;
  
  // Access semantic colors
  final successColor = context.successColor;
  final warningColor = context.warningColor;
  final infoColor = context.infoColor;
  
  return Container(
    color: theme.scaffoldBackgroundColor,
    child: Text(
      'Hello',
      style: textTheme.headlineMedium,
    ),
  );
}
```

### Changing Theme

```dart
// Via SettingsProvider (recommended - persists theme)
final settingsProvider = context.read<SettingsProvider>();
await settingsProvider.updateThemeMode(ThemeMode.dark);

// Via ThemeProvider directly (doesn't persist)
final themeProvider = context.read<ThemeProvider>();
themeProvider.setThemeMode(ThemeMode.light);

// Toggle theme
themeProvider.toggleTheme();
```

### Using Glassmorphism Components

#### GlassContainer

```dart
import 'package:markey_app/core/theme/widgets/widgets.dart';

GlassContainer(
  width: 300,
  height: 200,
  padding: EdgeInsets.all(16),
  borderRadius: BorderRadius.circular(20),
  blur: 15.0,
  opacity: 0.15,
  child: Text('Glassmorphism Effect'),
)
```

#### GlassCard

```dart
GlassCard(
  padding: EdgeInsets.all(20),
  onTap: () {
    // Handle tap
  },
  child: Column(
    children: [
      Text('Card Title'),
      Text('Card Content'),
    ],
  ),
)
```

#### GlassButton

```dart
GlassButton(
  onPressed: () {
    // Handle press
  },
  child: Text(
    'Glass Button',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

#### GlassAppBar

```dart
GlassAppBar(
  title: Text('My App'),
  actions: [
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {},
    ),
  ],
)
```

### Using Theme Constants

```dart
import 'package:markey_app/core/theme/theme_constants.dart';

Container(
  padding: ThemeConstants.paddingMd,
  margin: ThemeConstants.paddingLg,
  decoration: BoxDecoration(
    borderRadius: ThemeConstants.borderRadiusLg,
  ),
  child: Icon(
    Icons.star,
    size: ThemeConstants.iconMd,
  ),
)
```

### Using Semantic Colors

```dart
// Get semantic color based on current theme
final successColor = AppTheme.getSemanticColor(
  context,
  SemanticColor.success,
);

final primaryColor = AppTheme.getSemanticColor(
  context,
  SemanticColor.primary,
);

// Available semantic colors:
// - SemanticColor.success (green)
// - SemanticColor.warning (orange)
// - SemanticColor.info (blue)
// - SemanticColor.error (red)
// - SemanticColor.primary (indigo)
// - SemanticColor.secondary (purple)
// - SemanticColor.accent (cyan)
```

### Custom Glassmorphism

```dart
GlassContainer(
  blur: ThemeConstants.glassBlurHeavy,
  opacity: ThemeConstants.glassOpacityMedium,
  color: Colors.blue.withOpacity(0.1),
  border: Border.all(
    color: Colors.blue.withOpacity(0.3),
    width: 2,
  ),
  child: YourWidget(),
)
```

## Color Palette

### Light Mode
- Primary: Indigo (#6366F1)
- Secondary: Purple (#8B5CF6)
- Accent: Cyan (#06B6D4)
- Success: Green (#10B981)
- Warning: Orange (#F59E0B)
- Info: Blue (#3B82F6)
- Error: Red (#EF4444)
- Background: Light Gray (#F8FAFC)
- Surface: White (#FFFFFF)

### Dark Mode
- Primary: Light Indigo (#818CF8)
- Secondary: Light Purple (#A78BFA)
- Accent: Light Cyan (#22D3EE)
- Success: Light Green (#34D399)
- Warning: Light Orange (#FBBF24)
- Info: Light Blue (#60A5FA)
- Error: Light Red (#F87171)
- Background: Dark Blue (#0F172A)
- Surface: Dark Gray (#1E293B)

## Typography

All text uses the Inter font family from Google Fonts with the following styles:

- Display Large: 57px, Regular
- Display Medium: 45px, Regular
- Display Small: 36px, Regular
- Headline Large: 32px, Semibold
- Headline Medium: 28px, Semibold
- Headline Small: 24px, Semibold
- Title Large: 22px, Medium
- Title Medium: 16px, Medium
- Title Small: 14px, Medium
- Body Large: 16px, Regular
- Body Medium: 14px, Regular
- Body Small: 12px, Regular
- Label Large: 14px, Medium
- Label Medium: 12px, Medium
- Label Small: 11px, Medium

## Architecture

The theme system follows Clean Architecture principles:

```
lib/core/theme/
├── app_theme.dart              # Main theme configuration
├── theme_provider.dart         # State management for theme
├── theme_service.dart          # Abstract theme service interface
├── theme_service_impl.dart     # Theme service implementation
├── theme_constants.dart        # Spacing, sizing constants
├── theme_extensions.dart       # Extension methods for easy access
├── theme.dart                  # Barrel file
└── widgets/
    ├── glass_container.dart    # Base glassmorphism container
    ├── glass_card.dart         # Glassmorphism card
    ├── glass_button.dart       # Glassmorphism button
    ├── glass_app_bar.dart      # Glassmorphism app bar
    └── widgets.dart            # Barrel file
```

## Integration with Settings

Theme preference is automatically persisted through the SettingsRepository:

1. User changes theme via SettingsProvider
2. SettingsProvider updates ThemeProvider
3. SettingsProvider saves to SettingsRepository
4. SettingsRepository encrypts and stores in SecureStorage
5. On app restart, settings are loaded and theme is restored

## Best Practices

1. **Use semantic colors** instead of hardcoded colors
2. **Use theme constants** for consistent spacing and sizing
3. **Use context extensions** for easy theme access
4. **Persist theme changes** via SettingsProvider
5. **Use glassmorphism sparingly** for visual hierarchy
6. **Test in both light and dark modes**
7. **Use Material 3 components** for consistency

## Examples

See the following screens for implementation examples:
- `lib/features/auth/presentation/screens/onboarding_screen.dart`
- `lib/features/vault/presentation/screens/vault_screen.dart`
- `lib/features/settings/presentation/screens/settings_screen.dart`
