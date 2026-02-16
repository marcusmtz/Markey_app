import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/category.dart';

/// Category filter chips with animated selection
class CategoryFilterChips extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length + 1, // +1 for "All" chip
            itemBuilder: (context, index) {
              if (index == 0) {
                // "All" chip
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildChip(
                    context,
                    theme,
                    label: 'All',
                    isSelected: selectedCategory == null,
                    onTap: () => onCategorySelected(null),
                    color: theme.colorScheme.primary,
                  ),
                );
              }

              final category = categories[index - 1];
              final color = _parseColor(category.colorHex);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildChip(
                  context,
                  theme,
                  label: category.name,
                  isSelected: selectedCategory == category.id,
                  onTap: () => onCategorySelected(category.id),
                  color: color,
                ),
              );
            },
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms)
        .slideY(begin: -0.3, end: 0, duration: 300.ms);
  }

  Widget _buildChip(
    BuildContext context,
    ThemeData theme, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: theme.colorScheme.surface,
        selectedColor: color.withValues(alpha: 0.2),
        checkmarkColor: color,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          color: isSelected ? color : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected
              ? color
              : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}
