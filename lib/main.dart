import 'package:flutter/material.dart';
import 'package:flutter_demos/numpad/pin_entry_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PinEntryForm(
              validator: (code) => code == '123456',
              onSubmit: (code) => debugPrint('Executed payload value: $code'),
              onCancel: () => debugPrint('Transaction cancelled.'),
            ),
          ),
        ),
      ),
    );
  }
}
