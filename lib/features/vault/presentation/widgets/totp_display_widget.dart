import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../totp/domain/totp_service.dart';

/// TOTP code display with countdown timer
class TotpDisplayWidget extends StatefulWidget {
  final String secret;
  final Function(String) onCopy;

  const TotpDisplayWidget({
    super.key,
    required this.secret,
    required this.onCopy,
  });

  @override
  State<TotpDisplayWidget> createState() => _TotpDisplayWidgetState();
}

class _TotpDisplayWidgetState extends State<TotpDisplayWidget> {
  Timer? _timer;
  String _currentCode = '';
  int _remainingSeconds = 30;

  @override
  void initState() {
    super.initState();
    _generateCode();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateCode() {
    try {
      final totpService = context.read<TotpService>();
      setState(() {
        _currentCode = totpService.generateCode(widget.secret);
        _remainingSeconds = totpService.getRemainingSeconds();
      });
    } catch (e) {
      setState(() {
        _currentCode = 'ERROR';
        _remainingSeconds = 0;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final totpService = context.read<TotpService>();
      final remaining = totpService.getRemainingSeconds();

      setState(() {
        _remainingSeconds = remaining;
      });

      // Regenerate code when it expires
      if (remaining == 30 || remaining == 0) {
        _generateCode();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpiringSoon = _remainingSeconds <= 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.security, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              '2FA Code',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // TOTP Code
            Expanded(
              child:
                  Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isExpiringSoon
                                ? Colors.orange
                                : theme.colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          _formatCode(_currentCode),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            color: isExpiringSoon
                                ? Colors.orange
                                : theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .then(delay: isExpiringSoon ? 500.ms : 0.ms)
                      .shimmer(
                        duration: isExpiringSoon ? 500.ms : 0.ms,
                        color: Colors.orange.withValues(alpha: 0.3),
                      ),
            ),
            const SizedBox(width: 12),

            // Circular Timer
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _remainingSeconds / 30,
                    strokeWidth: 4,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isExpiringSoon
                          ? Colors.orange
                          : theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    '$_remainingSeconds',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isExpiringSoon
                          ? Colors.orange
                          : theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Copy Button
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => widget.onCopy(_currentCode),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatCode(String code) {
    if (code.length == 6) {
      return '${code.substring(0, 3)} ${code.substring(3)}';
    }
    return code;
  }
}
