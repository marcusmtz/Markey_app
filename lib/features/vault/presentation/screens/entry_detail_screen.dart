import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/clipboard_service.dart';
import '../../../../core/utils/result.dart';
import '../../../generator/domain/password_generator_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/category.dart';
import '../../domain/entry.dart';
import '../../domain/vault_repository.dart';
import '../widgets/password_field_widget.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/totp_display_widget.dart';
import '../widgets/password_history_widget.dart';
import '../widgets/password_generator_dialog.dart';

/// Entry detail/edit screen with Hero animation
class EntryDetailScreen extends StatefulWidget {
  final Entry? entry; // null for new entry
  final String? heroTag;

  const EntryDetailScreen({super.key, this.entry, this.heroTag});

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _urlController;
  late final TextEditingController _notesController;
  late final TextEditingController _totpSecretController;

  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isSaving = false;
  List<String> _selectedCategories = [];
  PasswordStrength _passwordStrength = PasswordStrength.weak;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.entry == null;

    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _usernameController = TextEditingController(
      text: widget.entry?.username ?? '',
    );
    _passwordController = TextEditingController(
      text: widget.entry?.password ?? '',
    );
    _urlController = TextEditingController(text: widget.entry?.url ?? '');
    _notesController = TextEditingController(text: widget.entry?.notes ?? '');
    _totpSecretController = TextEditingController(
      text: widget.entry?.totpSecret ?? '',
    );
    _selectedCategories = List.from(widget.entry?.categories ?? []);

    // Evaluate initial password strength
    if (_passwordController.text.isNotEmpty) {
      _evaluatePasswordStrength();
    }

    // Listen to password changes
    _passwordController.addListener(_evaluatePasswordStrength);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    _totpSecretController.dispose();
    super.dispose();
  }

  void _evaluatePasswordStrength() {
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordStrength = PasswordStrength.weak);
      return;
    }

    final generator = context.read<PasswordGeneratorService>();
    setState(() {
      _passwordStrength = generator.evaluateStrength(_passwordController.text);
    });
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = context.read<VaultRepository>();
      final now = DateTime.now();

      final entry = Entry(
        id:
            widget.entry?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        url: _urlController.text.trim().isEmpty
            ? null
            : _urlController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        categories: _selectedCategories,
        isFavorite: widget.entry?.isFavorite ?? false,
        totpSecret: _totpSecretController.text.trim().isEmpty
            ? null
            : _totpSecretController.text.trim(),
        passwordHistory: widget.entry?.passwordHistory ?? [],
        createdAt: widget.entry?.createdAt ?? now,
        updatedAt: now,
        accessCount: widget.entry?.accessCount ?? 0,
      );

      print('EntryDetail: Saving entry: ${entry.title}'); // DEBUG

      final result = widget.entry == null
          ? await repository.createEntry(entry)
          : await repository.updateEntry(entry);

      print('EntryDetail: Save result: ${result.isSuccess}'); // DEBUG

      if (result.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.entry == null ? 'Entry created' : 'Entry updated',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        print(
          'EntryDetail: Save error: ${result.errorOrNull?.message}',
        ); // DEBUG
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.errorOrNull?.message ?? 'Failed to save entry',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _showPasswordGenerator() async {
    final generated = await showDialog<String>(
      context: context,
      builder: (context) => const PasswordGeneratorDialog(),
    );

    if (generated != null && mounted) {
      setState(() {
        _passwordController.text = generated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.entry == null ? 'New Entry' : 'Entry Details'),
        actions: [
          if (!_isEditing && widget.entry != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveEntry,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title Field
            _buildGlassCard(
              child: TextFormField(
                controller: _titleController,
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  prefixIcon: const Icon(Icons.title),
                  border: _isEditing
                      ? const OutlineInputBorder()
                      : InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Username Field
            _buildGlassCard(
                  child: TextFormField(
                    controller: _usernameController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person),
                      suffixIcon:
                          !_isEditing && _usernameController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () => _copyToClipboard(
                                _usernameController.text,
                                'Username',
                              ),
                            )
                          : null,
                      border: _isEditing
                          ? const OutlineInputBorder()
                          : InputBorder.none,
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 200.ms, delay: 50.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Password Field with Strength Indicator
            _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PasswordFieldWidget(
                        controller: _passwordController,
                        enabled: _isEditing,
                        onCopy: !_isEditing
                            ? () => _copyToClipboard(
                                _passwordController.text,
                                'Password',
                              )
                            : null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),
                      if (_isEditing) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: PasswordStrengthIndicator(
                                strength: _passwordStrength,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _showPasswordGenerator,
                              icon: const Icon(Icons.auto_awesome, size: 18),
                              label: const Text('Generate'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 200.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // URL Field
            _buildGlassCard(
                  child: TextFormField(
                    controller: _urlController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: 'URL',
                      prefixIcon: const Icon(Icons.link),
                      border: _isEditing
                          ? const OutlineInputBorder()
                          : InputBorder.none,
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 200.ms, delay: 150.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // TOTP Section
            if (widget.entry?.totpSecret != null || _isEditing)
              _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isEditing && widget.entry?.totpSecret != null)
                          TotpDisplayWidget(
                            secret: widget.entry!.totpSecret!,
                            onCopy: (code) =>
                                _copyToClipboard(code, 'TOTP code'),
                          )
                        else
                          TextFormField(
                            controller: _totpSecretController,
                            enabled: _isEditing,
                            decoration: InputDecoration(
                              labelText: 'TOTP Secret (Base32)',
                              prefixIcon: const Icon(Icons.security),
                              border: _isEditing
                                  ? const OutlineInputBorder()
                                  : InputBorder.none,
                              helperText: 'Optional: Add 2FA secret key',
                            ),
                          ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 200.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),

            if ((widget.entry?.totpSecret != null || _isEditing))
              const SizedBox(height: 16),

            // Notes Field
            _buildGlassCard(
                  child: TextFormField(
                    controller: _notesController,
                    enabled: _isEditing,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      prefixIcon: const Icon(Icons.notes),
                      border: _isEditing
                          ? const OutlineInputBorder()
                          : InputBorder.none,
                      alignLabelWithHint: true,
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 200.ms, delay: 250.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Categories Selection
            if (_isEditing)
              _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.category, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Categories',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: Category.getPredefinedCategories().map((
                              cat,
                            ) {
                              final isSelected = _selectedCategories.contains(
                                cat.id,
                              );
                              return FilterChip(
                                label: Text(cat.name),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    const noCategoryId = 'sin-categoria';

                                    if (selected) {
                                      // Si selecciona "Sin categoría", remover todas las demás
                                      if (cat.id == noCategoryId) {
                                        _selectedCategories.clear();
                                        _selectedCategories.add(cat.id);
                                      } else {
                                        // Si selecciona otra categoría, remover "Sin categoría"
                                        _selectedCategories.remove(
                                          noCategoryId,
                                        );
                                        _selectedCategories.add(cat.id);
                                      }
                                    } else {
                                      _selectedCategories.remove(cat.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 200.ms, delay: 275.ms)
                  .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Password History
            if (widget.entry != null &&
                widget.entry!.passwordHistory.isNotEmpty)
              _buildGlassCard(
                    child: PasswordHistoryWidget(
                      history: widget.entry!.passwordHistory,
                      onCopy: (password) =>
                          _copyToClipboard(password, 'Password from history'),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 200.ms, delay: 300.ms)
                  .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface.withValues(alpha: 0.9),
            theme.colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
        border: Border.all(
          width: 1.5,
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  Future<void> _copyToClipboard(String text, String label) async {
    final clipboardService = context.read<ClipboardService>();
    final settingsProvider = context.read<SettingsProvider>();
    await clipboardService.copyWithAutoClear(
      text,
      settingsProvider.settings.clipboardClearDuration,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copied to clipboard'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
