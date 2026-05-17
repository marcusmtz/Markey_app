import 'package:flutter/material.dart';

/// Password field with visibility toggle and copy button
class PasswordFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback? onCopy;
  final String? Function(String?)? validator;

  const PasswordFieldWidget({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onCopy,
    this.validator,
  });

  @override
  State<PasswordFieldWidget> createState() => _PasswordFieldWidgetState();
}

class _PasswordFieldWidgetState extends State<PasswordFieldWidget>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
      if (_obscureText) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: 'Password *',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _toggleVisibility,
                );
              },
            ),
            if (widget.onCopy != null && widget.controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: widget.onCopy,
              ),
          ],
        ),
        border: widget.enabled ? const OutlineInputBorder() : InputBorder.none,
      ),
      validator: widget.validator,
    );
  }
}
