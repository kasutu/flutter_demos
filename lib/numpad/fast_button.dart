import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FastButton extends StatefulWidget {
  const FastButton({
    super.key,
    required this.child,
    required this.onTap,
    required this.color,
    required this.enableHaptics,
    this.isDisabled = false,
  });

  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final bool enableHaptics;
  final bool isDisabled;

  @override
  State<FastButton> createState() => FastButtonState();
}

class FastButtonState extends State<FastButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // If disabled, return a dead container with lowered opacity.
    // By completely omitting the Listener, we guarantee zero misfires or haptics.
    if (widget.isDisabled) {
      return Container(
        alignment: Alignment.center,
        color: widget.color.withValues(alpha: 0.3),
        child: Opacity(opacity: 0.5, child: widget.child),
      );
    }

    final displayColor = _isPressed
        ? Color.alphaBlend(Colors.black.withValues(alpha: 0.18), widget.color)
        : widget.color;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        if (widget.enableHaptics) HapticFeedback.heavyImpact();
        setState(() => _isPressed = true);

        widget.onTap();
      },
      onPointerUp: (event) => setState(() => _isPressed = false),
      onPointerCancel: (event) => setState(() => _isPressed = false),
      child: Container(
        alignment: Alignment.center,
        color: displayColor,
        child: widget.child,
      ),
    );
  }
}
