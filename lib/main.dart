import 'package:flutter/material.dart';
import 'package:flutter_demos/access_code_display.dart';
import 'package:flutter_demos/fast_numpad.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(padding: EdgeInsets.all(16), child: NumpadDemo()),
        ),
      ),
    );
  }
}

class NumpadDemo extends StatefulWidget {
  const NumpadDemo({super.key});

  @override
  State<NumpadDemo> createState() => _NumpadDemoState();
}

class _NumpadDemoState extends State<NumpadDemo> {
  final int _codeLength = 6;

  // Single source of truth for the input
  final TextEditingController _controller = TextEditingController();

  final ValueNotifier<bool> _errorNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (_errorNotifier.value) {
        _errorNotifier.value = false;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _errorNotifier.dispose();
    super.dispose();
  }

  void _handleEnter() {
    final input = _controller.text;

    if (input != '123456') {
      debugPrint('Validation failed for: $input');
      _errorNotifier.value = true;
      return;
    }

    // Success Logic
    debugPrint('Executed payload value: $input');
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 24,
      children: [
        AccessCodeDisplay(
          controller: _controller,
          errorNotifier: _errorNotifier,
        ),
        FastNumpad(
          controller: _controller,
          requiredCharacterLength: _codeLength,
          onError: () => _errorNotifier.value = true,
          onCancelPressed: () {
            debugPrint('Transaction cancelled.');
            _controller.clear();
            _errorNotifier.value = false;
          },
          onEnterPressed: _handleEnter,
        ),
      ],
    );
  }
}
