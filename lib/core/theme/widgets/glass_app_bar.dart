import 'dart:ui';
import 'package:flutter/material.dart';

/// A glassmorphism app bar widget
/// Provides a frosted glass effect for app bars
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double blur;
  final double opacity;
  final Color? backgroundColor;

  const GlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark
        ? Colors.white.withValues(alpha: opacity)
        : Colors.white.withValues(alpha: opacity * 1.5);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: AppBar(
          title: title,
          actions: actions,
          leading: leading,
          automaticallyImplyLeading: automaticallyImplyLeading,
          backgroundColor: backgroundColor ?? defaultColor,
          elevation: 0,
          centerTitle: true,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
