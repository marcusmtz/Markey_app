# Password Generator Screen Integration Example

## Overview

This document provides examples of how to integrate the Password Generator Screen into your application.

## Setup

### 1. Provider Configuration

First, ensure the `PasswordGeneratorService` is available in your widget tree. Update your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/generator/domain/password_generator_service.dart';
import 'features/generator/data/password_generator_service_impl.dart';

void main() {
  runApp(const MarkeyApp());
}

class MarkeyApp extends StatelessWidget {
  const MarkeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Password Generator Service
        Provider<PasswordGeneratorService>(
          create: (_) => PasswordGeneratorServiceImpl(),
        ),
        // Add other providers here...
      ],
      child: MaterialApp(
        title: 'Markey Password Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
```

## Usage Examples

### Example 1: Navigate to Full Screen Generator

```dart
import 'package:flutter/material.dart';
import 'package:markey_app/features/generator/presentation/screens/password_generator_screen.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Screen')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PasswordGeneratorScreen(),
              ),
            );
          },
          icon: const Icon(Icons.vpn_key),
          label: const Text('Generate Password'),
        ),
      ),
    );
  }
}
```

### Example 2: Use Generator and Receive Password

```dart
import 'package:flutter/material.dart';
import 'package:markey_app/features/generator/presentation/screens/password_generator_screen.dart';

class CreateEntryScreen extends StatefulWidget {
  const CreateEntryScreen({super.key});

  @override
  State<CreateEntryScreen> createState() => _CreateEntryScreenState();
}

class _CreateEntryScreenState extends State<CreateEntryScreen> {
  final _passwordController = TextEditingController();

  Future<void> _openPasswordGenerator() async {
    final generatedPassword = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const PasswordGeneratorScreen(),
      ),
    );

    if (generatedPassword != null && mounted) {
      setState(() {
        _passwordController.text = generatedPassword;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.auto_awesome),
                  onPressed: _openPasswordGenerator,
                  tooltip: 'Generate Password',
                ),
              ),
              obscureText: true,
            ),
            // Other form fields...
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
```

### Example 3: Add to Navigation Drawer

```dart
import 'package:flutter/material.dart';
import 'package:markey_app/features/generator/presentation/screens/password_generator_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
            ),
            child: Text(
              'Markey',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Vault'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to vault
            },
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text('Password Generator'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PasswordGeneratorScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security Analysis'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to security analysis
            },
          ),
          // More menu items...
        ],
      ),
    );
  }
}
```

### Example 4: Add to Bottom Navigation

```dart
import 'package:flutter/material.dart';
import 'package:markey_app/features/generator/presentation/screens/password_generator_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const VaultScreen(),
    const PasswordGeneratorScreen(),
    const SecurityAnalysisScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.lock_outline),
            selectedIcon: Icon(Icons.lock),
            label: 'Vault',
          ),
          NavigationDestination(
            icon: Icon(Icons.vpn_key_outlined),
            selectedIcon: Icon(Icons.vpn_key),
            label: 'Generator',
          ),
          NavigationDestination(
            icon: Icon(Icons.security_outlined),
            selectedIcon: Icon(Icons.security),
            label: 'Security',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
```

### Example 5: Use as Modal Bottom Sheet

```dart
import 'package:flutter/material.dart';
import 'package:markey_app/features/generator/presentation/screens/password_generator_screen.dart';

void showPasswordGeneratorSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: const PasswordGeneratorScreen(),
      ),
    ),
  );
}

// Usage:
ElevatedButton(
  onPressed: () => showPasswordGeneratorSheet(context),
  child: const Text('Generate Password'),
)
```

## Customization

### Custom Route Transition

Add a custom page route for smoother transitions:

```dart
class SlidePageRoute extends PageRouteBuilder {
  final Widget page;

  SlidePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}

// Usage:
Navigator.push(
  context,
  SlidePageRoute(page: const PasswordGeneratorScreen()),
);
```

## Testing Integration

Test the integration in your app:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:markey_app/features/generator/domain/password_generator_service.dart';
import 'package:markey_app/features/generator/data/password_generator_service_impl.dart';
import 'package:markey_app/features/generator/presentation/screens/password_generator_screen.dart';

void main() {
  testWidgets('Can navigate to password generator', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<PasswordGeneratorService>(
          create: (_) => PasswordGeneratorServiceImpl(),
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PasswordGeneratorScreen(),
                      ),
                    );
                  },
                  child: const Text('Generate'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Generate'));
    await tester.pumpAndSettle();

    expect(find.text('Password Generator'), findsOneWidget);
  });
}
```

## Notes

- The screen requires `PasswordGeneratorService` to be provided via Provider
- The screen can return a generated password when popped from the navigation stack
- All animations are built-in and require no additional configuration
- The screen is fully responsive and works on all screen sizes
- Glassmorphism effects automatically adapt to light/dark themes
