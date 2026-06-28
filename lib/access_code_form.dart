import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_demos/fast_numpad.dart';

/// A reusable 6-digit access code entry widget.
///
/// Composes the existing [FastNumpad] to avoid duplicating button logic.
class AccessCodeEntry extends StatefulWidget {
  const AccessCodeEntry({
    super.key,
    required this.controller,
    this.length = 6,
    this.autoSubmit = true,
    this.obscureText = true,
    this.allowEmptySubmit = false,
    this.title,
    this.subtitle,
    this.validator,
    this.onSubmitted,
    this.onError,
    this.onClear,
    this.onCancel,
    this.shakeOnError = true,
    this.errorFlashDuration = const Duration(milliseconds: 400),
    this.buttonWidth = 72,
    this.buttonHeight = 72,
    this.gridSpacing = 1.0,
    this.enableHaptics = true,
  });

  final TextEditingController controller;
  final int length;
  final bool autoSubmit;
  final bool obscureText;
  final bool allowEmptySubmit;
  final String? title;
  final String? subtitle;
  final String? Function(String code)? validator;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onError;
  final VoidCallback? onClear;
  final VoidCallback? onCancel;
  final bool shakeOnError;
  final Duration errorFlashDuration;
  final double buttonWidth;
  final double buttonHeight;
  final double gridSpacing;
  final bool enableHaptics;

  @override
  State<AccessCodeEntry> createState() => _AccessCodeEntryState();
}

class _AccessCodeEntryState extends State<AccessCodeEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant AccessCodeEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _shakeController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() => _isError = false);

    if (widget.controller.text.length == widget.length && widget.autoSubmit) {
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted && widget.controller.text.length == widget.length) {
          _submit();
        }
      });
    }
  }

  void _submit() {
    final code = widget.controller.text;

    if (!widget.allowEmptySubmit && code.isEmpty) {
      _triggerError();
      return;
    }
    if (code.length < widget.length) {
      _triggerError();
      return;
    }

    if (widget.validator != null) {
      final err = widget.validator!(code);
      if (err != null) {
        _triggerError();
        return;
      }
    }

    widget.onSubmitted?.call(code);
  }

  void _triggerError() {
    widget.onError?.call();
    setState(() => _isError = true);
    if (widget.shakeOnError) _shakeController.forward(from: 0);
    Future.delayed(widget.errorFlashDuration, () {
      if (mounted) setState(() => _isError = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shake = widget.shakeOnError
            ? _shakeOffset(_shakeController.value)
            : 0.0;
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          if (widget.subtitle != null) ...[
            Text(
              widget.subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
          _buildDisplay(),
          const SizedBox(height: 32),
          FastNumpad(
            controller: widget.controller,
            onEnterPressed: _submit,
            onCancelPressed: () => widget.onCancel?.call(),
            allowEmptySubmit: true, // We gate submission ourselves
            enableHaptics: widget.enableHaptics,
            buttonWidth: widget.buttonWidth,
            buttonHeight: widget.buttonHeight,
            gridSpacing: widget.gridSpacing,
          ),
        ],
      ),
    );
  }

  double _shakeOffset(double t) {
    final decay = 1 - t;
    return 10 * math.sin(t * math.pi * 6) * decay;
  }

  Widget _buildDisplay() {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.outlineVariant;
    final code = widget.controller.text;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        final hasDigit = index < code.length;
        final digit = hasDigit ? code[index] : null;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 48,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: _isError
                  ? errorColor
                  : (hasDigit ? activeColor : inactiveColor),
              width: hasDigit || _isError ? 2.2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
            color: _isError
                ? errorColor.withValues(alpha: 0.08)
                : (hasDigit
                      ? activeColor.withValues(alpha: 0.06)
                      : theme.colorScheme.surface),
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 120),
            child: hasDigit
                ? Text(
                    widget.obscureText ? '•' : digit!,
                    key: ValueKey('d$index'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: _isError
                          ? errorColor
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  )
                : Text(
                    '—',
                    key: ValueKey('e$index'),
                    style: TextStyle(
                      color: inactiveColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}
