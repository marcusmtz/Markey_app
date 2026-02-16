import 'package:flutter/material.dart';

/// Widget that provides shake animation for error feedback
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;

  const ShakeWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.offset = 10.0,
  });

  @override
  State<ShakeWidget> createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: widget.offset),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.offset, end: -widget.offset),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -widget.offset, end: widget.offset),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.offset, end: -widget.offset),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -widget.offset, end: 0.0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Trigger the shake animation
  void shake() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
