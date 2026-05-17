# Markey Password Manager - Project Structure

This project follows Clean Architecture principles with clear separation of concerns.

## Architecture Overview

```
lib/
├── core/                    # Shared utilities and configurations
│   ├── constants/          # Application-wide constants
│   ├── errors/             # Error types and failure classes
│   ├── theme/              # Theme configuration (light/dark mode)
│   └── utils/              # Utility classes (Result type, etc.)
│
├── features/               # Feature modules (Clean Architecture)
│   ├── auth/              # Authentication & Authorization
│   ├── vault/             # Password vault management
│   ├── generator/         # Password generator
│   ├── security/          # Security analysis
│   ├── totp/              # TOTP/2FA codes
│   ├── backup/            # Backup & restore
│   └── settings/          # App settings
│
└── main.dart              # Application entry point
```

## Feature Module Structure

Each feature follows the same three-layer architecture:

```
feature_name/
├── data/                  # Data layer
│   ├── models/           # Data models with JSON serialization
│   ├── datasources/      # Local/remote data sources
│   └── repositories/     # Repository implementations
│
├── domain/               # Domain layer (business logic)
│   ├── entities/        # Business entities
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Use cases (business operations)
│
└── presentation/        # Presentation layer (UI)
    ├── pages/          # Screen widgets
    ├── widgets/        # Reusable UI components
    └── providers/      # State management (Provider/Riverpod)
```

## Dependencies

### Security & Storage
- `flutter_secure_storage` - Encrypted key storage
- `encrypt` - AES-256-GCM encryption
- `local_auth` - Biometric authentication
- `crypto` - Cryptographic functions

### Functionality
- `otp` - TOTP code generation
- `password_strength` - Password validation
- `qr_code_scanner` - QR code scanning
- `share_plus` - File sharing
- `path_provider` - File system access

### UI & Animations
- `flutter_animate` - Declarative animations
- `google_fonts` - Typography
- `flutter_slidable` - Swipe actions
- `shimmer` - Loading effects
- `flutter_staggered_animations` - Staggered list animations
- `glassmorphism` - Glass effect UI
- `flutter_svg` - SVG icons
- `lottie` - Complex animations

### State Management
- `provider` - Reactive state management

## Theme System

The app supports both light and dark themes with:
- Material 3 design
- Google Fonts (Inter)
- Glassmorphism effects
- Smooth transitions
- System theme detection

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

3. Run tests:
   ```bash
   flutter test
   ```

4. Analyze code:
   ```bash
   flutter analyze
   ```

## Next Steps

Follow the implementation tasks in `.kiro/specs/markey-password-manager/tasks.md` to build out the features incrementally.
