import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../domain/security_analyzer_service.dart';

/// Card displaying a security issue with glassmorphism effect
class SecurityIssueCard extends StatelessWidget {
  final SecurityIssue issue;
  final VoidCallback? onTap;

  const SecurityIssueCard({super.key, required this.issue, this.onTap});

  IconData _getIconForType(SecurityIssueType type) {
    switch (type) {
      case SecurityIssueType.weakPassword:
        return Icons.lock_open;
      case SecurityIssueType.duplicatePassword:
        return Icons.content_copy;
      case SecurityIssueType.compromisedPassword:
        return Icons.warning;
      case SecurityIssueType.reusedPassword:
        return Icons.repeat;
    }
  }

  Color _getColorForSeverity(SecurityIssueSeverity severity) {
    switch (severity) {
      case SecurityIssueSeverity.low:
        return Colors.blue;
      case SecurityIssueSeverity.medium:
        return Colors.orange;
      case SecurityIssueSeverity.high:
        return Colors.deepOrange;
      case SecurityIssueSeverity.critical:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = _getColorForSeverity(issue.severity);

    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 100,
        borderRadius: 16,
        blur: 10,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface.withValues(alpha: 0.9),
            theme.colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            severityColor.withValues(alpha: 0.5),
            severityColor.withValues(alpha: 0.3),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon with colored background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForType(issue.type),
                  color: severityColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Issue details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            issue.entryTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: severityColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            issue.severity.description,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: severityColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      issue.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow icon
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
