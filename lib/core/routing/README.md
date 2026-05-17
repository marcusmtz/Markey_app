# Routing Module

This module provides centralized navigation and routing functionality for the Markey Password Manager app.

## Components

### AppRouter
Central router that handles all route generation with animated transitions.

**Usage:**
```dart
MaterialApp(
  onGenerateRoute: AppRouter.generateRoute,
  initialRoute: RouteNames.onboarding,
)
```

### RouteNames
Centralized route name constants to avoid magic strings.

**Available Routes:**
- `RouteNames.onboarding` - First-time setup screen
- `RouteNames.login` - Authentication screen
- `RouteNames.vault` - Main vault screen
- `RouteNames.entryDetail` - Entry detail/edit screen
- `RouteNames.passwordGenerator` - Password generator screen
- `RouteNames.securityAnalysis` - Security analysis screen
- `RouteNames.notesList` - Secure notes list screen
- `RouteNames.noteEditor` - Note editor screen
- `RouteNames.settings` - Settings screen

**Usage:**
```dart
Navigator.of(context).pushNamed(RouteNames.vault);

// With arguments
Navigator.of(context).pushNamed(
  RouteNames.entryDetail,
  arguments: EntryDetailArguments(entry: myEntry),
);
```

### RouteTransitions
Custom animated transitions for routes.

**Available Transitions:**
- `slideTransition` - Slide from right to left
- `fadeTransition` - Fade in/out
- `slideAndFadeTransition` - Combined slide and fade (default for most screens)
- `scaleTransition` - Scale with fade (useful for modals)

**Usage:**
```dart
Navigator.of(context).push(
  RouteTransitions.slideAndFadeTransition(
    MyScreen(),
    RouteSettings(name: '/my-screen'),
  ),
);
```

### AuthGuard
Authentication guard for protected routes.

**Usage:**
```dart
// Navigate to protected route
AuthGuard.navigateToProtectedRoute(
  context,
  RouteNames.vault,
);

// Wrap widget with authentication check
AuthGuardWidget(
  child: VaultScreen(),
  fallback: LoginScreen(),
)
```

## Features

### Animated Transitions
All routes use smooth animated transitions:
- Slide + Fade for main navigation
- Fade for auth screens
- Hero animations for entry details

### Authentication Guards
Protected routes automatically redirect to login if user is not authenticated.

### Type-Safe Arguments
Route arguments are type-safe using dedicated argument classes:
- `EntryDetailArguments` - For entry detail screen
- `NoteEditorArguments` - For note editor screen

### Error Handling
Unknown routes display a user-friendly error screen with navigation back.

## Implementation Details

### Transition Duration
All transitions use a consistent 300ms duration for smooth UX.

### Route Settings
Each route preserves its settings for proper navigation stack management.

### Deep Linking Support
The routing system is designed to support deep linking (can be extended as needed).

## Example Usage

### Basic Navigation
```dart
// Navigate to a screen
Navigator.of(context).pushNamed(RouteNames.settings);

// Navigate with replacement
Navigator.of(context).pushReplacementNamed(RouteNames.vault);

// Navigate and clear stack
Navigator.of(context).pushNamedAndRemoveUntil(
  RouteNames.vault,
  (route) => false,
);
```

### Navigation with Arguments
```dart
// Navigate to entry detail
Navigator.of(context).pushNamed(
  RouteNames.entryDetail,
  arguments: EntryDetailArguments(
    entry: myEntry,
    heroTag: 'entry_123',
  ),
);

// Navigate to note editor
Navigator.of(context).pushNamed(
  RouteNames.noteEditor,
  arguments: NoteEditorArguments(note: myNote),
);
```

### Protected Navigation
```dart
// Navigate to protected route with auth check
await AuthGuard.navigateToProtectedRoute(
  context,
  RouteNames.vault,
);
```

## Requirements Satisfied

This implementation satisfies **Requirement 15.1**:
- ✅ Rutas con transiciones animadas
- ✅ Guards de autenticación configurados
- ✅ Soporte para deep linking (estructura preparada)
- ✅ Transiciones slide + fade implementadas
