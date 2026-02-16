import 'package:flutter/material.dart';

/// Custom route transitions for the application
class RouteTransitions {
  /// Duration for all transitions
  static const Duration _transitionDuration = Duration(milliseconds: 300);

  /// Slide transition from right to left
  static Route<T> slideTransition<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: _transitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Fade transition
  static Route<T> fadeTransition<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: _transitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Combined slide and fade transition
  static Route<T> slideAndFadeTransition<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: _transitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var slideTween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        var fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Scale transition (useful for modals)
  static Route<T> scaleTransition<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: _transitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;

        var scaleTween = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        var fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }
}
