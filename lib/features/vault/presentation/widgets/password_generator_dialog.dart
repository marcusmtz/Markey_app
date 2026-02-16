import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../generator/domain/password_generator_service.dart';
import 'password_strength_indicator.dart';

/// Dialog for generating passwords inline
class PasswordGeneratorDialog extends StatefulWidget {
  const PasswordGeneratorDialog({super.key});

  @override
  State<PasswordGeneratorDialog> createState() =>
      _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
  int _length = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  String _generatedPassword = '';
  PasswordStrength _strength = PasswordStrength.weak;

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    final generator = context.read<PasswordGeneratorService>();
    final config = PasswordGeneratorConfig(
      length: _length,
      includeUppercase: _includeUppercase,
      includeLowercase: _includeLowercase,
      includeNumbers: _includeNumbers,
      includeSymbols: _includeSymbols,
    );

    try {
      setState(() {
        _generatedPassword = generator.generate(config);
        _strength = generator.evaluateStrength(_generatedPassword);
      });
    } catch (e) {
      setState(() {
        _generatedPassword = 'Error: ${e.toString()}';
        _strength = PasswordStrength.weak;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface.withValues(alpha: 0.95),
              theme.colorScheme.surface.withValues(alpha: 0.9),
            ],
          ),
          border: Border.all(
            width: 2,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Generate Password',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Generated Password Display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _generatedPassword,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: _generatePassword,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 16),

                // Strength Indicator
                PasswordStrengthIndicator(strength: _strength),

                const SizedBox(height: 24),

                // Length Slider
                Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        'Length: $_length',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _length.toDouble(),
                        min: 8,
                        max: 64,
                        divisions: 56,
                        label: _length.toString(),
                        onChanged: (value) {
                          setState(() => _length = value.toInt());
                          _generatePassword();
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Character Type Switches
                _buildSwitch('Uppercase (A-Z)', _includeUppercase, (value) {
                  setState(() => _includeUppercase = value);
                  _generatePassword();
                }),
                _buildSwitch('Lowercase (a-z)', _includeLowercase, (value) {
                  setState(() => _includeLowercase = value);
                  _generatePassword();
                }),
                _buildSwitch('Numbers (0-9)', _includeNumbers, (value) {
                  setState(() => _includeNumbers = value);
                  _generatePassword();
                }),
                _buildSwitch('Symbols (!@#\$%)', _includeSymbols, (value) {
                  setState(() => _includeSymbols = value);
                  _generatePassword();
                }),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_generatedPassword),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('Use Password'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
