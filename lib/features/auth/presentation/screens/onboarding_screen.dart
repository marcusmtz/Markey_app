import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/utils/result.dart';
import '../providers/auth_provider.dart';
import '../widgets/password_field.dart';

/// Onboarding screen for first-time setup
/// Allows user to create master password or PIN
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _usePassword = true; // true for password, false for PIN
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handleSetup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();

    try {
      final result = _usePassword
          ? await authProvider.setupMasterPassword(_passwordController.text)
          : await authProvider.setupMasterPin(_pinController.text);

      if (!mounted) return;

      if (result.isSuccess) {
        // Navigate to vault screen after successful setup
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(RouteNames.vault, (route) => false);
      } else {
        _showError(result.errorOrNull?.message ?? 'Setup failed');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.secondary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Welcome Icon
                Icon(
                  Icons.lock_outline,
                  size: 120,
                  color: theme.colorScheme.primary,
                ).animate().fadeIn(duration: 600.ms).scale(),

                const SizedBox(height: 32),

                // Welcome Text
                Text(
                  'Welcome to Markey',
                  style: theme.textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 12),

                Text(
                  'Secure your passwords with ease',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 48),

                // Form Container with Glassmorphism
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.surface.withValues(alpha: 0.9),
                              theme.colorScheme.surface.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            width: 2,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Toggle between Password and PIN
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ToggleButton(
                                        label: 'Password',
                                        isSelected: _usePassword,
                                        onTap: () {
                                          setState(() {
                                            _usePassword = true;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _ToggleButton(
                                        label: 'PIN',
                                        isSelected: !_usePassword,
                                        onTap: () {
                                          setState(() {
                                            _usePassword = false;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Password or PIN Fields
                                if (_usePassword) ...[
                                  PasswordField(
                                    controller: _passwordController,
                                    label: 'Master Password',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password is required';
                                      }
                                      if (value.length < 8) {
                                        return 'Password must be at least 8 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  PasswordField(
                                    controller: _confirmPasswordController,
                                    label: 'Confirm Password',
                                    validator: (value) {
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ] else ...[
                                  TextFormField(
                                    controller: _pinController,
                                    decoration: const InputDecoration(
                                      labelText: 'Master PIN',
                                      prefixIcon: Icon(Icons.pin),
                                    ),
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                    maxLength: 6,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'PIN is required';
                                      }
                                      if (!RegExp(r'^\d+$').hasMatch(value)) {
                                        return 'PIN must contain only digits';
                                      }
                                      if (value.length < 4) {
                                        return 'PIN must be at least 4 digits';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _confirmPinController,
                                    decoration: const InputDecoration(
                                      labelText: 'Confirm PIN',
                                      prefixIcon: Icon(Icons.pin),
                                    ),
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                    maxLength: 6,
                                    validator: (value) {
                                      if (value != _pinController.text) {
                                        return 'PINs do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ],

                                const SizedBox(height: 24),

                                // Setup Button
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSetup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Get Started',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.onPrimary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                // Security Note
                Text(
                  'Your master password/PIN is used to encrypt all your data.\nMake sure to remember it - it cannot be recovered.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Toggle button widget for password/PIN selection
class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
