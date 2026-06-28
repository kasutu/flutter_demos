import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_demos/theme/industrial_colors.dart';

/// A pure-presentation, high-performance code display.
///
/// Under error conditions, surgically isolates feedback (red border + shake)
/// strictly to incomplete cells.
class PinDisplay extends StatefulWidget {
  const PinDisplay({
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
  State<PinDisplay> createState() => PinDisplayState();
}

class PinDisplayState extends State<PinDisplay>
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
    if (widget.errorNotifier.value) _shakeController.forward(from: 0.0);
  }

  void _onErrorTriggered() {
    if (widget.errorNotifier.value) _shakeController.forward(from: 0.0);
  }

  @override
  void dispose() {
    widget.errorNotifier.removeListener(_onErrorTriggered);
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cellMargin = EdgeInsets.symmetric(horizontal: widget.cellGap / 2);

    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.controller,
        widget.errorNotifier,
        _shakeController,
      ]),
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        final industrialColors = context.industrialColors;

        final text = widget.controller.text;
        final isError = widget.errorNotifier.value;
        final isFullyFilled = text.length == widget.requiredLength;

        final normalStyle = TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: scheme.onSurface,
        );
        final errorStyle = normalStyle.copyWith(color: scheme.error);

        final rawShakeOffset = sin(_shakeController.value * pi * 4) * 8.0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.requiredLength, (index) {
            final isFilled = index < text.length;
            final isFaulty = isError && (isFullyFilled || !isFilled);

            Color borderColor;
            double borderWidth;
            TextStyle activeStyle;

            if (isFaulty) {
              borderColor = scheme.error;
              borderWidth = 2.0;
              activeStyle = errorStyle;
            } else if (isFilled) {
              borderColor = scheme.primary;
              borderWidth = 2.0;
              activeStyle = normalStyle;
            } else {
              borderColor = scheme.outlineVariant;
              borderWidth = 1.0;
              activeStyle = normalStyle;
            }

            return Transform.translate(
              offset: Offset(isFaulty ? rawShakeOffset : 0.0, 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: widget.cellSize,
                height: widget.cellSize,
                margin: cellMargin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: industrialColors.input,
                  border: Border.all(color: borderColor, width: borderWidth),
                ),
                child: Text(
                  isFilled ? (widget.obscureText ? '*' : text[index]) : '',
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
