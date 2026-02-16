import 'package:flutter/material.dart';

/// Dialog for selecting theme mode
class ThemeSelectorDialog extends StatelessWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onSelected;

  const ThemeSelectorDialog({
    super.key,
    required this.currentTheme,
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
            Text(
              'Seleccionar tema',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            _ThemeOption(
              icon: Icons.light_mode,
              title: 'Claro',
              isSelected: currentTheme == ThemeMode.light,
              onTap: () {
                onSelected(ThemeMode.light);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 12),
            _ThemeOption(
              icon: Icons.dark_mode,
              title: 'Oscuro',
              isSelected: currentTheme == ThemeMode.dark,
              onTap: () {
                onSelected(ThemeMode.dark);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 12),
            _ThemeOption(
              icon: Icons.brightness_auto,
              title: 'Automático',
              isSelected: currentTheme == ThemeMode.system,
              onTap: () {
                onSelected(ThemeMode.system);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
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
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
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
}
