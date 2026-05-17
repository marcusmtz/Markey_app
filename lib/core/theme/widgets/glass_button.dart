import 'package:flutter/material.dart';
import 'glass_container.dart';

/// A glassmorphism button widget
/// Provides a frosted glass effect for buttons
class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? color;
  final double blur;
  final double opacity;

  const GlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
    this.blur = 10.0,
    this.opacity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: GlassContainer(
        width: width ?? double.infinity,
        height: height ?? 56,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        blur: blur,
        opacity: opacity,
        color: color,
        child: Center(child: child),
      ),
    );
  }
}
