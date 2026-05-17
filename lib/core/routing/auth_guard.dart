import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'route_names.dart';

/// Authentication guard for protected routes
/// Redirects to login if user is not authenticated
class AuthGuard {
  /// Check if user is authenticated and redirect if necessary
  static Future<bool> checkAuth(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    return authProvider.isAuthenticated;
  }

  /// Navigate to a protected route with authentication check
  static Future<T?> navigateToProtectedRoute<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    final isAuthenticated = await checkAuth(context);

    if (!isAuthenticated) {
      // Redirect to login
      if (context.mounted) {
        return Navigator.of(context).pushReplacementNamed(RouteNames.login);
      }
      return null;
    }

    // Navigate to the requested route
    if (context.mounted) {
      return Navigator.of(context).pushNamed(routeName, arguments: arguments);
    }
    return null;
  }

  /// Push replacement to a protected route with authentication check
  static Future<T?> pushReplacementToProtectedRoute<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    final isAuthenticated = await checkAuth(context);

    if (!isAuthenticated) {
      // Redirect to login
      if (context.mounted) {
        return Navigator.of(context).pushReplacementNamed(RouteNames.login);
      }
      return null;
    }

    // Navigate to the requested route
    if (context.mounted) {
      return Navigator.of(
        context,
      ).pushReplacementNamed(routeName, arguments: arguments);
    }
    return null;
  }
}

/// Widget wrapper that enforces authentication
class AuthGuardWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AuthGuardWidget({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return child;
        }

        // Show fallback or redirect to login
        if (fallback != null) {
          return fallback!;
        }

        // Redirect to login after frame is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed(RouteNames.login);
          }
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
