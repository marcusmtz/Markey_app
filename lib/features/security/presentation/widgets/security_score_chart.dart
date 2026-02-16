import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated circular chart displaying security score
class SecurityScoreChart extends StatefulWidget {
  final double score;
  final double size;

  const SecurityScoreChart({super.key, required this.score, this.size = 200});

  @override
  State<SecurityScoreChart> createState() => _SecurityScoreChartState();
}

class _SecurityScoreChartState extends State<SecurityScoreChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.score,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(SecurityScoreChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(begin: oldWidget.score, end: widget.score)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final score = _animation.value;
        final color = _getScoreColor(score);
        final label = _getScoreLabel(score);

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CirclePainter(
                  progress: 1.0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  strokeWidth: 16,
                ),
              ),

              // Progress circle
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CirclePainter(
                  progress: score / 100,
                  color: color,
                  strokeWidth: 16,
                ),
              ),

              // Score text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${score.toInt()}',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: widget.size * 0.25,
                    ),
                  ),
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CirclePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
