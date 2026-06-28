import 'package:flutter/material.dart';

/// A bare-metal, variable-length code display.
///
/// Purely presentational. Does NOT mutate the controller.
/// Length gating must be handled by the input source (e.g., Numpad).
class AccessCodeDisplay extends StatelessWidget {
  const AccessCodeDisplay({
    super.key,
    required this.controller,
    this.requiredLength = 6,
    this.cellGap = 8.0, // Typed as double for strictness
    this.cellSize = 52.0,
    this.obscureText = true,
    this.isError = false,
  });

  final TextEditingController controller;
  final int requiredLength;
  final double cellGap;
  final double cellSize;
  final bool obscureText;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // 1. Pre-resolve colors outside the builder loop
    final errorColor = scheme.error;
    final primaryColor = scheme.primary;
    final outlineColor = scheme.outlineVariant;
    final onSurfaceColor = scheme.onSurface;

    // 2. Pre-allocate TextStyles to avoid allocating N styles per keystroke
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

    // 3. Pre-allocate the margin object
    final cellMargin = EdgeInsets.symmetric(horizontal: cellGap / 2);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final text = value.text;
        final len = text.length;

        // Pre-determine the active style for this build frame
        final activeStyle = isError ? errorStyle : normalStyle;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(requiredLength, (index) {
            final filled = index < len;

            // Determine border color logic efficiently
            final borderColor = isError
                ? errorColor
                : (filled ? primaryColor : outlineColor);

            return Container(
              width: cellSize,
              height: cellSize,
              margin: cellMargin, // Replaces the Padding widget wrapper
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 2.0),
              ),
              child: Text(
                filled ? (obscureText ? '*' : text[index]) : '',
                style: activeStyle,
              ),
            );
          }),
        );
      },
    );
  }
}
