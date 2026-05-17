import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/generator/presentation/screens/password_generator_screen.dart';
import '../../features/notes/presentation/screens/note_editor_screen.dart';
import '../../features/notes/presentation/screens/notes_list_screen.dart';
import '../../features/security/presentation/screens/security_analysis_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/vault/presentation/screens/categories_screen.dart';
import '../../features/vault/presentation/screens/entry_detail_screen.dart';
import '../../features/vault/presentation/screens/vault_screen.dart';
import 'route_names.dart';
import 'route_transitions.dart';

/// Central router for the application
/// Handles all route generation with animated transitions
class AppRouter {
  /// Generate routes with appropriate transitions
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth routes
      case RouteNames.onboarding:
        return RouteTransitions.fadeTransition(
          const OnboardingScreen(),
          settings,
        );

      case RouteNames.login:
        return RouteTransitions.fadeTransition(const LoginScreen(), settings);

      // Main vault route
      case RouteNames.vault:
        return RouteTransitions.slideTransition(const VaultScreen(), settings);

      // Entry detail route
      case RouteNames.entryDetail:
        final args = settings.arguments as EntryDetailArguments?;
        return RouteTransitions.slideAndFadeTransition(
          EntryDetailScreen(entry: args?.entry, heroTag: args?.heroTag),
          settings,
        );

      // Password generator route
      case RouteNames.passwordGenerator:
        return RouteTransitions.slideAndFadeTransition(
          const PasswordGeneratorScreen(),
          settings,
        );

      // Security analysis route
      case RouteNames.securityAnalysis:
        return RouteTransitions.slideAndFadeTransition(
          const SecurityAnalysisScreen(),
          settings,
        );

      // Notes routes
      case RouteNames.notesList:
        return RouteTransitions.slideAndFadeTransition(
          const NotesListScreen(),
          settings,
        );

      case RouteNames.noteEditor:
        final args = settings.arguments as NoteEditorArguments?;
        return RouteTransitions.slideAndFadeTransition(
          NoteEditorScreen(note: args?.note),
          settings,
        );

      // Settings route
      case RouteNames.settings:
        return RouteTransitions.slideAndFadeTransition(
          const SettingsScreen(),
          settings,
        );

      // Categories route
      case RouteNames.categories:
        return RouteTransitions.slideAndFadeTransition(
          const CategoriesScreen(),
          settings,
        );

      // Default/unknown route
      default:
        return RouteTransitions.fadeTransition(
          _ErrorScreen(routeName: settings.name ?? 'unknown'),
          settings,
        );
    }
  }
}

/// Error screen for unknown routes
class _ErrorScreen extends StatelessWidget {
  final String routeName;

  const _ErrorScreen({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Route not found: $routeName',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
