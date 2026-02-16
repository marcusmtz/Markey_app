import 'package:flutter/material.dart';

/// Dialog for selecting duration values
class DurationSelectorDialog extends StatelessWidget {
  final String title;
  final Duration currentDuration;
  final List<Duration> options;
  final Function(Duration) onSelected;

  const DurationSelectorDialog({
    super.key,
    required this.title,
    required this.currentDuration,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            ...options.map((duration) {
              final isSelected = duration == currentDuration;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DurationOption(
                  duration: duration,
                  isSelected: isSelected,
                  onTap: () {
                    onSelected(duration);
                    Navigator.of(context).pop();
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _DurationOption extends StatelessWidget {
  final Duration duration;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationOption({
    required this.duration,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _formatDuration(duration),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return '${duration.inSeconds} segundos';
    } else if (duration.inMinutes == 1) {
      return '1 minuto';
    } else {
      return '${duration.inMinutes} minutos';
    }
  }
}
