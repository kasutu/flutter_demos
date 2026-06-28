import 'package:flutter/material.dart';
import 'package:flutter_demos/numpad/pin_display.dart';
import 'package:flutter_demos/numpad/fast_numpad.dart';

class PinEntryForm extends StatefulWidget {
  const PinEntryForm({
    super.key,
    this.codeLength = 6,
    required this.onSubmit,
    this.onCancel,
    this.validator,
  });

  final int codeLength;
  final void Function(String code) onSubmit;
  final VoidCallback? onCancel;
  final bool Function(String code)? validator;

  @override
  State<PinEntryForm> createState() => PinEntryFormState();
}

class PinEntryFormState extends State<PinEntryForm> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _errorNotifier = ValueNotifier(false);

  // track length, not just "any change"
  int _prevLength = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _errorNotifier.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    final len = _controller.text.length;

    // Only clear the error when the user is actively typing new input.
    // Ignores length decreases so that FastNumpad's internal post-enter
    // clear doesn't race with and wipe the error before it renders.
    if (_errorNotifier.value && len > _prevLength) {
      _errorNotifier.value = false;
    }
    _prevLength = len;
  }

  void _handleEnter() {
    final code = _controller.text;
    final isValid = widget.validator?.call(code) ?? true;

    if (!isValid) {
      _errorNotifier.value = true;
      return;
    }

    widget.onSubmit(code);
    _controller.clear();
  }

  void _handleCancel() {
    _controller.clear();
    _errorNotifier.value = false;
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 64,
      children: [
        PinDisplay(controller: _controller, errorNotifier: _errorNotifier),
        FastNumpad(
          enableHaptics: true,
          controller: _controller,
          requiredCharacterLength: widget.codeLength,
          onError: () => _errorNotifier.value = true,
          onCancelPressed: _handleCancel,
          onEnterPressed: _handleEnter,
        ),
      ],
    );
  }
}
