import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:provider/provider.dart';
import '../../domain/password_generator_service.dart';
import '../../../vault/presentation/widgets/password_strength_indicator.dart';

/// Full screen password generator with advanced options
class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen>
    with SingleTickerProviderStateMixin {
  int _length = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  String _generatedPassword = '';
  PasswordStrength _strength = PasswordStrength.weak;
  bool _isRegenerating = false;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _generatePassword();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
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
        _isRegenerating = true;
        _generatedPassword = generator.generate(config);
        _strength = generator.evaluateStrength(_generatedPassword);
      });

      // Trigger rotation animation
      _rotationController.forward(from: 0);

      // Reset regenerating state after animation
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _isRegenerating = false);
        }
      });
    } catch (e) {
      setState(() {
        _generatedPassword = 'Error: ${e.toString()}';
        _strength = PasswordStrength.weak;
        _isRegenerating = false;
      });
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Password copied to clipboard'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'Information',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Glassmorphic Container with Password Display
            GlassmorphicContainer(
                  width: double.infinity,
                  height: 280,
                  borderRadius: 24,
                  blur: 20,
                  alignment: Alignment.center,
                  border: 2,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.surface.withValues(alpha: 0.95),
                      theme.colorScheme.surface.withValues(alpha: 0.9),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.5),
                      theme.colorScheme.secondary.withValues(alpha: 0.5),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Password Display
                        Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: SelectableText(
                                _generatedPassword,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                            .animate(key: ValueKey(_generatedPassword))
                            .fadeIn(duration: 300.ms),

                        const SizedBox(height: 20),

                        // Strength Indicator
                        PasswordStrengthIndicator(strength: _strength),

                        const SizedBox(height: 24),

                        // Action Buttons Row
                        Row(
                          children: [
                            // Regenerate Button
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isRegenerating
                                    ? null
                                    : _generatePassword,
                                icon: RotationTransition(
                                  turns: _rotationController,
                                  child: const Icon(Icons.refresh),
                                ),
                                label: const Text('Regenerate'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Copy Button
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _generatedPassword.isEmpty
                                    ? null
                                    : _copyToClipboard,
                                icon: const Icon(Icons.copy),
                                label: const Text('Copy'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  backgroundColor: theme.colorScheme.secondary,
                                  foregroundColor:
                                      theme.colorScheme.onSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(
                  begin: -0.2,
                  end: 0,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                ),

            const SizedBox(height: 32),

            // Configuration Section
            Text(
              'Configuration',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            // Length Slider Card
            _buildConfigCard(
                  theme,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Password Length',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$_length',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 24,
                          ),
                        ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '8',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          Text(
                            '64',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms)
                .slideX(begin: -0.1, end: 0, duration: 400.ms),

            const SizedBox(height: 16),

            // Character Types Card
            _buildConfigCard(
                  theme,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Character Types',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildAnimatedSwitch(
                        theme,
                        'Uppercase Letters (A-Z)',
                        Icons.text_fields,
                        _includeUppercase,
                        (value) {
                          setState(() => _includeUppercase = value);
                          _generatePassword();
                        },
                        0,
                      ),
                      _buildAnimatedSwitch(
                        theme,
                        'Lowercase Letters (a-z)',
                        Icons.text_fields,
                        _includeLowercase,
                        (value) {
                          setState(() => _includeLowercase = value);
                          _generatePassword();
                        },
                        1,
                      ),
                      _buildAnimatedSwitch(
                        theme,
                        'Numbers (0-9)',
                        Icons.numbers,
                        _includeNumbers,
                        (value) {
                          setState(() => _includeNumbers = value);
                          _generatePassword();
                        },
                        2,
                      ),
                      _buildAnimatedSwitch(
                        theme,
                        'Symbols (!@#\$%)',
                        Icons.tag,
                        _includeSymbols,
                        (value) {
                          setState(() => _includeSymbols = value);
                          _generatePassword();
                        },
                        3,
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms)
                .slideX(begin: -0.1, end: 0, duration: 400.ms),

            const SizedBox(height: 32),

            // Use Password Button
            FilledButton.icon(
                  onPressed: _generatedPassword.isEmpty
                      ? null
                      : () => Navigator.of(context).pop(_generatedPassword),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Use This Password'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 500.ms)
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigCard(ThemeData theme, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildAnimatedSwitch(
    ThemeData theme,
    String label,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    int index,
  ) {
    return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onChanged(!value),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: value
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: value
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                        ),
                      ),
                    ),
                    Switch(value: value, onChanged: onChanged),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 400 + (index * 50)))
        .fadeIn(duration: 300.ms);
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Password Strength',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStrengthInfo(
              context,
              'Weak',
              Colors.red,
              'Less than 40 bits of entropy',
            ),
            const SizedBox(height: 8),
            _buildStrengthInfo(
              context,
              'Medium',
              Colors.orange,
              '40-60 bits of entropy',
            ),
            const SizedBox(height: 8),
            _buildStrengthInfo(
              context,
              'Strong',
              Colors.green,
              '60-80 bits of entropy',
            ),
            const SizedBox(height: 8),
            _buildStrengthInfo(
              context,
              'Very Strong',
              Colors.blue,
              '80+ bits of entropy',
            ),
            const SizedBox(height: 16),
            Text(
              'Tip: Use longer passwords with multiple character types for better security.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthInfo(
    BuildContext context,
    String label,
    Color color,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
