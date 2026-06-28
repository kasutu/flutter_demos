import 'package:flutter/material.dart';
import 'package:flutter_demos/simple_numpad.dart';

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
  // Use a numeric ValueNotifier to hold the pure integer value
  final ValueNotifier<int> _numericController = ValueNotifier<int>(0);

  // Holds the history of submitted values
  final List<int> _history = [];

  // Tracks whether the display is currently flashing red for an error
  bool _isFlashingError = false;

  @override
  void dispose() {
    _numericController.dispose();
    super.dispose();
  }

  /// Briefly flashes the display red to indicate a validation error.
  void _flashError() {
    setState(() => _isFlashingError = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isFlashingError = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display Section — flashes red when _isFlashingError is true
        ValueListenableBuilder<int>(
          valueListenable: _numericController,
          builder: (context, value, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _isFlashingError
                  ? Colors.red.shade400
                  : Colors.grey.shade200,
              child: Text(
                '$value',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // History Header
        const Text(
          'History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const Divider(),

        // History List Section
        Expanded(
          child: _history.isEmpty
              ? const Center(
                  child: Text(
                    'No entries yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      title: Text(
                        '${_history[index]}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  },
                ),
        ),

        // Pure Industrial Numpad
        Center(
          child: SimpleNumpad(
            allowZeroSubmit: false,
            controller: _numericController,
            onCancelPressed: () {
              debugPrint('Transaction cancelled.');
            },
            onEnterPressed: () {
              debugPrint('Executed payload value: ${_numericController.value}');
              // Add current value to history and reset the controller
              setState(() {
                _history.add(_numericController.value);
                _numericController.value =
                    0; // Optional: Resets numpad after enter
              });
            },
            onError: () {
              _flashError();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Zero is not a valid input')),
              );
            },
          ),
        ),
      ],
    );
  }
}
