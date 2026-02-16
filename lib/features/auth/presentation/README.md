# Authentication Presentation Layer

This directory contains the UI components for authentication.

## Screens

### OnboardingScreen
First-time setup screen where users create their master password or PIN.

**Features:**
- Lottie animation for welcome experience
- Toggle between password and PIN setup
- Glassmorphism effects
- Form validation
- Integration with AuthService

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const OnboardingScreen()),
);
```

### LoginScreen
Authentication screen for returning users.

**Features:**
- Password or PIN authentication
- Biometric authentication support (if available)
- Shake animation for errors
- Lock status display (after 3 failed attempts)
- Glassmorphism effects

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const LoginScreen()),
);
```

## Widgets

### PasswordField
Reusable password input field with visibility toggle.

### ShakeWidget
Widget that provides shake animation for error feedback.

## Provider

### AuthProvider
State management for authentication using Provider pattern.

**Setup in main.dart:**
```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            AuthServiceImpl(
              SecureStorageServiceImpl(),
              LocalAuthentication(),
            ),
          )..initialize(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

## Navigation Flow

1. **First Launch:** Show OnboardingScreen
2. **Subsequent Launches:** Show LoginScreen
3. **After Authentication:** Navigate to '/vault' (main app)

## Assets Required

Place a Lottie animation file at:
- `assets/animations/welcome.json`

If the animation is not found, a fallback lock icon will be displayed.

## Requirements Implemented

- **Requisito 2.1:** Master password/PIN setup
- **Requisito 2.2:** Authentication with password/PIN
- **Requisito 2.3:** Biometric authentication
- **Requisito 2.4:** Lock after 3 failed attempts
- **Requisito 15.1:** Modern UI with animations
- **Requisito 15.3:** Glassmorphism effects
