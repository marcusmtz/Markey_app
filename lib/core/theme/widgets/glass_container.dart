import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable glassmorphism container widget
/// Provides a frosted glass effect with blur and transparency
class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacity;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.color,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark
        ? Colors.white.withValues(alpha: opacity)
        : Colors.white.withValues(alpha: opacity * 1.5);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border:
            border ??
            Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: color ?? defaultColor,
              borderRadius: borderRadius ?? BorderRadius.circular(16),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
