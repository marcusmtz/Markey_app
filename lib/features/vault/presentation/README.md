# Vault Presentation Layer

This directory contains the presentation layer for the vault feature, including the main vault screen with password entries.

## Components

### Screens
- `vault_screen.dart` - Main vault screen with search, filters, and entry list

### Widgets
- `entry_card.dart` - Card displaying entry information with glassmorphism and slidable actions
- `search_bar_widget.dart` - Animated search bar
- `category_filter_chips.dart` - Category filter chips with animations

### Providers
- `vault_provider.dart` - State management for vault operations

## Usage Example

To integrate the vault screen into your app:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/vault/presentation/screens/vault_screen.dart';
import 'features/vault/presentation/providers/vault_provider.dart';
import 'features/vault/data/vault_repository_impl.dart';
import 'core/services/encryption_service.dart';
import 'core/services/secure_storage_service.dart';

// In your main app or routing:
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (context) => VaultProvider(
        repository: VaultRepositoryImpl(
          encryptionService: context.read<EncryptionService>(),
          storageService: context.read<SecureStorageService>(),
          masterKey: 'your-master-key', // From authentication
        ),
      ),
    ),
  ],
  child: const VaultScreen(),
)
```

## Features

### Search and Filter
- Real-time search across title, username, URL, and notes
- Category filtering with animated chips
- Combined filters with AND logic
- Clear filters option

### Entry Card
- Glassmorphism design
- Favicon display from URL
- Category badges
- 2FA indicator
- Favorite star indicator

### Slidable Actions
- **Swipe Right**: Copy password, Toggle favorite
- **Swipe Left**: Edit entry, Delete entry

### Animations
- Staggered list animations on load
- Search bar expansion animation
- FAB scale animation
- Shimmer loading effect
- Smooth transitions

## Requirements Implemented

- **6.1**: Real-time search and filtering
- **15.2**: Staggered animations for list items
- **15.5**: Shimmer loading effects
- **16.1-16.5**: Slidable actions for quick operations
- **15.3**: Glassmorphism effects on cards
