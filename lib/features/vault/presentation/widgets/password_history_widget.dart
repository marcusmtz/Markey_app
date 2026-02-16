import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../domain/entry.dart';

/// Expandable password history widget
class PasswordHistoryWidget extends StatefulWidget {
  final List<PasswordHistory> history;
  final Function(String) onCopy;

  const PasswordHistoryWidget({
    super.key,
    required this.history,
    required this.onCopy,
  });

  @override
  State<PasswordHistoryWidget> createState() => _PasswordHistoryWidgetState();
}

class _PasswordHistoryWidgetState extends State<PasswordHistoryWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.history, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Password History (${widget.history.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 8),
          ...widget.history.asMap().entries.map((entry) {
            final index = entry.key;
            final historyItem = entry.value;

            return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _obscurePassword(historyItem.password),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(historyItem.changedAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () => widget.onCopy(historyItem.password),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 200.ms, delay: (index * 50).ms)
                .slideX(begin: -0.1, end: 0);
          }),
        ],
      ],
    );
  }

  String _obscurePassword(String password) {
    if (password.length <= 4) {
      return '•' * password.length;
    }
    return password.substring(0, 2) +
        ('•' * (password.length - 4)) +
        password.substring(password.length - 2);
  }
}
