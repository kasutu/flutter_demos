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
  // Single TextEditingController drives both display and numpad
  final TextEditingController _controller = TextEditingController();

  // Tracks whether the display is currently flashing red for an error
  bool _isFlashingError = false;

  // Required length for the access code
  final int _codeLength = 6;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Briefly flashes the background red to indicate a validation error.
  void _flashError() {
    setState(() => _isFlashingError = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isFlashingError = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Display Section
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: _isFlashingError ? Colors.red.shade50 : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: AccessCodeDisplay(
            controller: _controller,
            requiredLength: _codeLength,
          ),
        ),

        const SizedBox(height: 48),

        // Pure Industrial Numpad
        FastNumpad(
          controller: _controller,
          onCancelPressed: () {
            debugPrint('Transaction cancelled.');
            _controller.clear();
          },
          onEnterPressed: () {
            debugPrint('Executed payload value: ${_controller.text}');
            _controller.clear();
          },
          onError: () {
            _flashError();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Invalid input')));
          },
        ),
      ],
    );
  }
}
