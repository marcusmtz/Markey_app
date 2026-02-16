import 'package:flutter/material.dart';

/// A single settings item tile
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
        ),
      ),
      trailing:
          trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                )
              : null),
      onTap: onTap,
    );
  }
}
