import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/services/clipboard_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/category_provider.dart';
import '../providers/vault_provider.dart';
import '../widgets/entry_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_filter_chips.dart';

/// Main vault screen displaying password entries
class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    // Initialize and load entries when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vaultProvider = context.read<VaultProvider>();
      // Initialize with a temporary key if not already initialized
      // In a real app, this would come from the auth service
      if (!vaultProvider.isInitialized) {
        vaultProvider.initialize('temporary_master_key');
      }
      vaultProvider.loadEntries();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        _searchController.clear();
        context.read<VaultProvider>().search('');
      }
    });
  }

  void _onSearchChanged(String query) {
    context.read<VaultProvider>().search(query);
  }

  void _onCategorySelected(String? categoryId) {
    context.read<VaultProvider>().filterByCategory(categoryId);
  }

  void _onAddEntry() async {
    // Navigate to add entry screen using named route
    final result = await Navigator.of(
      context,
    ).pushNamed(RouteNames.entryDetail);

    if (result == true && mounted) {
      context.read<VaultProvider>().loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await _showExitDialog(context);
        if (shouldExit == true && context.mounted) {
          // Exit the app
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Remove back button
          centerTitle: false, // Align title to the left
          title: const Text('Markey'),
          actions: [
            Consumer<VaultProvider>(
              builder: (context, provider, child) {
                return IconButton(
                  icon: Icon(
                    provider.showOnlyFavorites ? Icons.star : Icons.star_border,
                    color: provider.showOnlyFavorites ? Colors.orange : null,
                  ),
                  onPressed: () => provider.toggleFavoritesFilter(),
                  tooltip: provider.showOnlyFavorites
                      ? 'Show all'
                      : 'Show favorites',
                );
              },
            ),
            IconButton(
              icon: Icon(_isSearchExpanded ? Icons.close : Icons.search),
              onPressed: _toggleSearch,
              tooltip: 'Search',
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'More options',
              onSelected: (value) {
                switch (value) {
                  case 'security':
                    Navigator.of(
                      context,
                    ).pushNamed(RouteNames.securityAnalysis);
                    break;
                  case 'notes':
                    Navigator.of(context).pushNamed(RouteNames.notesList);
                    break;
                  case 'generator':
                    Navigator.of(
                      context,
                    ).pushNamed(RouteNames.passwordGenerator);
                    break;
                  case 'categories':
                    Navigator.of(context).pushNamed(RouteNames.categories);
                    break;
                  case 'settings':
                    Navigator.of(context).pushNamed(RouteNames.settings);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'security',
                  child: Row(
                    children: [
                      Icon(Icons.security),
                      SizedBox(width: 12),
                      Text('Security Analysis'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'notes',
                  child: Row(
                    children: [
                      Icon(Icons.note_outlined),
                      SizedBox(width: 12),
                      Text('Secure Notes'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'generator',
                  child: Row(
                    children: [
                      Icon(Icons.vpn_key),
                      SizedBox(width: 12),
                      Text('Password Generator'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'categories',
                  child: Row(
                    children: [
                      Icon(Icons.category),
                      SizedBox(width: 12),
                      Text('Categorías'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 12),
                      Text('Settings'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar with expansion animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _isSearchExpanded ? 70 : 0,
              child: _isSearchExpanded
                  ? SearchBarWidget(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                    ).animate().fadeIn().slideY(begin: -0.5, end: 0)
                  : const SizedBox.shrink(),
            ),

            // Category Filter Chips
            Consumer2<VaultProvider, CategoryProvider>(
              builder: (context, vaultProvider, categoryProvider, child) {
                return CategoryFilterChips(
                  categories: categoryProvider.categories,
                  selectedCategory: vaultProvider.selectedCategory,
                  onCategorySelected: _onCategorySelected,
                );
              },
            ),

            // Entries List
            Expanded(
              child: Consumer<VaultProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return _buildShimmerLoading(theme);
                  }

                  if (provider.errorMessage != null) {
                    return _buildErrorState(
                      theme,
                      provider.errorMessage!,
                      () => provider.loadEntries(),
                    );
                  }

                  if (provider.entries.isEmpty) {
                    return _buildEmptyState(theme, provider.hasFilters);
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadEntries(),
                    child: AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.entries.length,
                        itemBuilder: (context, index) {
                          final entry = provider.entries[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: EntryCard(
                                    entry: entry,
                                    onTap: () async {
                                      // Navigate to entry detail
                                      provider.incrementAccessCount(entry.id);
                                      final result = await Navigator.of(context)
                                          .pushNamed(
                                            RouteNames.entryDetail,
                                            arguments: EntryDetailArguments(
                                              entry: entry,
                                              heroTag: 'entry_${entry.id}',
                                            ),
                                          );

                                      if (result == true && mounted) {
                                        provider.loadEntries();
                                      }
                                    },
                                    onEdit: () async {
                                      // Navigate to edit entry
                                      final result = await Navigator.of(context)
                                          .pushNamed(
                                            RouteNames.entryDetail,
                                            arguments: EntryDetailArguments(
                                              entry: entry,
                                              heroTag: 'entry_${entry.id}',
                                            ),
                                          );

                                      if (result == true && mounted) {
                                        provider.loadEntries();
                                      }
                                    },
                                    onDelete: () async {
                                      final confirmed = await _showDeleteDialog(
                                        context,
                                        entry.title,
                                      );
                                      if (confirmed == true) {
                                        await provider.deleteEntry(entry.id);
                                      }
                                    },
                                    onCopy: () async {
                                      // Copy password to clipboard
                                      final clipboardService = context
                                          .read<ClipboardService>();
                                      final settingsProvider = context
                                          .read<SettingsProvider>();
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );

                                      await clipboardService.copyWithAutoClear(
                                        entry.password,
                                        settingsProvider
                                            .settings
                                            .clipboardClearDuration,
                                      );

                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Password copied to clipboard',
                                          ),
                                          duration: Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    onToggleFavorite: () {
                                      provider.toggleFavorite(entry.id);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton:
            FloatingActionButton(
                  onPressed: _onAddEntry,
                  child: const Icon(Icons.add),
                )
                .animate()
                .scale(
                  delay: 400.ms,
                  duration: 300.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(),
      ),
    );
  }

  Widget _buildShimmerLoading(ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: theme.brightness == Brightness.light
          ? Colors.grey[300]!
          : Colors.grey[700]!,
      highlightColor: theme.brightness == Brightness.light
          ? Colors.grey[100]!
          : Colors.grey[600]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(
    ThemeData theme,
    String message,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Error', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool hasFilters) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.lock_open,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No Results' : 'No Entries Yet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your search or filters'
                  : 'Tap the + button to add your first password',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<VaultProvider>().clearFilters();
                  _searchController.clear();
                  setState(() {
                    _isSearchExpanded = false;
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Markey?'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
