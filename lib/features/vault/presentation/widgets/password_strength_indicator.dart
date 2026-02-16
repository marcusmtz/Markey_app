import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../generator/domain/password_generator_service.dart';

/// Visual indicator for password strength
class PasswordStrengthIndicator extends StatelessWidget {
  final PasswordStrength strength;

  const PasswordStrengthIndicator({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor();
    final progress = strength.score / 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strength.description,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Color _getColor() {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
      case PasswordStrength.veryStrong:
        return Colors.blue;
    }
  }
}
