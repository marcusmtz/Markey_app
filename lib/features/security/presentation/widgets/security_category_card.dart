import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

/// Card displaying a security category with glassmorphism effect
class SecurityCategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const SecurityCategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 150,
        borderRadius: 20,
        blur: 15,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface.withValues(alpha: 0.95),
            theme.colorScheme.surface.withValues(alpha: 0.85),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.5), color.withValues(alpha: 0.3)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon with gradient background
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.3),
                      color.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),

              const SizedBox(width: 16),

              // Category details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count.toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
