import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A high-performance, raw industrial numpad that adapts directly to the ambient Theme.
class FastNumpad extends StatelessWidget {
  const FastNumpad({
    super.key,
    this.buttonWidth = 92,
    this.buttonHeight = 92,
    this.gridSpacing = 1.0,
    required this.controller,
    required this.onEnterPressed,
    required this.onCancelPressed,
    this.allowEmptySubmit = false,
    this.onError,
    this.enableHaptics = true,
    this.backspaceIcon = Icons.backspace_outlined,
    this.backspaceSize = 24,
    this.textStyle,
    this.actionTextStyle,
    this.backgroundColor,
    this.backspaceBackgroundColor,
    this.clearBackgroundColor,
    this.cancelBackgroundColor,
    this.actionBackgroundColor,
    this.requiredCharacterLength,
    this.disableEnter,
  });

  final double buttonWidth;
  final double buttonHeight;
  final double gridSpacing;

  final TextEditingController controller;

  final VoidCallback onCancelPressed;
  final VoidCallback onEnterPressed;
  final bool allowEmptySubmit;
  final VoidCallback? onError;
  final bool enableHaptics;
  final IconData backspaceIcon;
  final double backspaceSize;

  final TextStyle? textStyle;
  final TextStyle? actionTextStyle;
  final Color? backgroundColor;
  final Color? backspaceBackgroundColor;
  final Color? clearBackgroundColor;
  final Color? cancelBackgroundColor;
  final Color? actionBackgroundColor;

  final int? requiredCharacterLength;
  final ValueListenable<bool>? disableEnter;

  void _inputDigit(int digit) {
    final currentValue = controller.text;

    // stop when complete
    if (requiredCharacterLength != null &&
        currentValue.length >= requiredCharacterLength!) {
      return;
    }

    final newText = currentValue + digit.toString();

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  void _inputBackspace() {
    final currentValue = controller.text;

    if (currentValue.isEmpty) return;

    final newText = currentValue.substring(0, currentValue.length - 1);

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  void _inputClear() {
    controller.clear();
  }

  void _handleSubmit() {
    if (!allowEmptySubmit && controller.value.text.isEmpty) {
      onError?.call();
      return;
    }

    // throw error when incomplete
    if (requiredCharacterLength != null &&
        controller.value.text.length < requiredCharacterLength!) {
      onError?.call();
      return;
    }

    onEnterPressed();
    _inputClear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalWidth = (buttonWidth * 4) + (gridSpacing * 3);
    final totalHeight = (buttonHeight * 4) + (gridSpacing * 3);

    final resolvedTextStyle = textStyle ?? theme.textTheme.headlineLarge;
    final resolvedActionTextStyle =
        actionTextStyle ?? theme.textTheme.labelLarge;

    final baseColor =
        backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final backspaceColor =
        backspaceBackgroundColor ?? theme.colorScheme.errorContainer;
    final clearColor =
        clearBackgroundColor ?? theme.colorScheme.surfaceContainer;
    final cancelColor = cancelBackgroundColor ?? theme.colorScheme.error;
    final actionColor = actionBackgroundColor ?? theme.colorScheme.primary;

    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: GridView.count(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: gridSpacing,
        mainAxisSpacing: gridSpacing,
        childAspectRatio: buttonWidth / buttonHeight,
        children: [
          // Row 1
          _padNumberButton(1, resolvedTextStyle, baseColor),
          _padNumberButton(2, resolvedTextStyle, baseColor),
          _padNumberButton(3, resolvedTextStyle, baseColor),
          _baseButton(
            color: backspaceColor,
            onTap: _inputBackspace,
            child: Icon(
              backspaceIcon,
              size: backspaceSize,
              color: backspaceBackgroundColor == null
                  ? theme.colorScheme.onErrorContainer
                  : null,
            ),
          ),

          // Row 2
          _padNumberButton(4, resolvedTextStyle, baseColor),
          _padNumberButton(5, resolvedTextStyle, baseColor),
          _padNumberButton(6, resolvedTextStyle, baseColor),
          _baseButton(
            color: clearColor,
            onTap: _inputClear,
            child: Text("CLEAR", style: resolvedActionTextStyle),
          ),

          // Row 3
          _padNumberButton(7, resolvedTextStyle, baseColor),
          _padNumberButton(8, resolvedTextStyle, baseColor),
          _padNumberButton(9, resolvedTextStyle, baseColor),
          _baseButton(
            color: cancelColor,
            onTap: () {
              onCancelPressed();
              _inputClear();
            },
            child: Text(
              "CANCEL",
              style: resolvedActionTextStyle?.copyWith(
                color: cancelBackgroundColor == null
                    ? theme.colorScheme.onError
                    : null,
              ),
            ),
          ),

          // Row 4
          const SizedBox.shrink(), // Left spacer
          _padNumberButton(0, resolvedTextStyle, baseColor),
          const SizedBox.shrink(), // Right spacer
          // ⚡ Isolated Enter Button Builder
          disableEnter == null
              ? _buildEnter(actionColor, resolvedActionTextStyle, theme, false)
              : ValueListenableBuilder<bool>(
                  valueListenable: disableEnter!,
                  builder: (context, isDisabled, _) {
                    return _buildEnter(
                      actionColor,
                      resolvedActionTextStyle,
                      theme,
                      isDisabled,
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEnter(
    Color actionColor,
    TextStyle? actionStyle,
    ThemeData theme,
    bool isDisabled,
  ) {
    return _baseButton(
      color: actionColor,
      onTap: _handleSubmit,
      isDisabled: isDisabled,
      child: Text(
        "ENTER",
        style: actionStyle?.copyWith(
          color: actionBackgroundColor == null
              ? theme.colorScheme.onPrimary
              : null,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _baseButton({
    required Widget child,
    required VoidCallback onTap,
    required Color color,
    bool isDisabled = false,
  }) {
    return _NumpadButton(
      color: color,
      onTap: onTap,
      enableHaptics: enableHaptics,
      isDisabled: isDisabled,
      child: child,
    );
  }

  Widget _padNumberButton(int digit, TextStyle? style, Color color) {
    return _baseButton(
      color: color,
      onTap: () => _inputDigit(digit),
      child: Text('$digit', style: style),
    );
  }
}

class _NumpadButton extends StatefulWidget {
  const _NumpadButton({
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
  State<_NumpadButton> createState() => _NumpadButtonState();
}

class _NumpadButtonState extends State<_NumpadButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // ⚡ If disabled, return a dead container with lowered opacity.
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
        if (widget.enableHaptics) HapticFeedback.lightImpact();
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
