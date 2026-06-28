import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// A pure-presentation, high-performance code display.
///
/// Under error conditions, surgically isolates feedback (red border + shake)
/// strictly to incomplete cells.
class AccessCodeDisplay extends StatefulWidget {
  const AccessCodeDisplay({
    super.key,
    required this.controller,
    required this.errorNotifier,
    this.requiredLength = 6,
    this.cellGap = 8.0,
    this.cellSize = 52.0,
    this.obscureText = true,
  });

  final TextEditingController controller;
  final ValueListenable<bool> errorNotifier;
  final int requiredLength;
  final double cellGap;
  final double cellSize;
  final bool obscureText;

  @override
  State<AccessCodeDisplay> createState() => _AccessCodeDisplayState();
}

class _AccessCodeDisplayState extends State<AccessCodeDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    widget.errorNotifier.addListener(_onErrorTriggered);

    if (widget.errorNotifier.value) {
      _shakeController.forward(from: 0.0);
    }
  }

  void _onErrorTriggered() {
    if (widget.errorNotifier.value) {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    widget.errorNotifier.removeListener(_onErrorTriggered);
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final errorColor = scheme.error;
    final primaryColor = scheme.primary;
    final outlineColor = scheme.outlineVariant;
    final onSurfaceColor = scheme.onSurface;

    final normalStyle = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: onSurfaceColor,
    );
    final errorStyle = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: errorColor,
    );

    final cellMargin = EdgeInsets.symmetric(horizontal: widget.cellGap / 2);

    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.controller,
        widget.errorNotifier,
        _shakeController,
      ]),
      builder: (context, _) {
        final text = widget.controller.text;
        final len = text.length;
        final isError = widget.errorNotifier.value;
        final isFullyFilled = len == widget.requiredLength;

        // Calculate translation offset once per tick frame
        final rawShakeOffset = sin(_shakeController.value * pi * 4) * 8.0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.requiredLength, (index) {
            final filled = index < len;

            // If code is fully filled but wrong -> everything shakes and turns red.
            // If code is partially filled -> only empty boxes shake and turn red.
            final cellIsFaulty = isError && (isFullyFilled || !filled);

            final currentOffset = cellIsFaulty ? rawShakeOffset : 0.0;
            final activeStyle = cellIsFaulty ? errorStyle : normalStyle;

            final borderColor = cellIsFaulty
                ? errorColor
                : (filled ? primaryColor : outlineColor);

            return Transform.translate(
              offset: Offset(currentOffset, 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: widget.cellSize,
                height: widget.cellSize,
                margin: cellMargin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: borderColor,
                    width: cellIsFaulty ? 3.0 : 2.0,
                  ),
                ),
                child: Text(
                  filled ? (widget.obscureText ? '*' : text[index]) : '',
                  style: activeStyle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
