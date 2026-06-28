import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Adjust this import to match your project's actual package name
import 'package:flutter_demos/main.dart';
import 'package:flutter_demos/fast_numpad.dart';

void main() {
  // Binds the test to the physical device UI
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Live UI Benchmark: 10 zero-heavy scenarios', (tester) async {
    // 1. Boot up the exact app UI you provided
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Pause for 2 seconds so you can get your eyes on the screen
    await Future.delayed(const Duration(seconds: 2));

    final scenarios = [
      '000000', // Pure zeros
      '010203', // Interspersed
      '007042', // Leading double zero
      '000123', // Leading triple zero
      '090800', // Trailing zeros
      '001000', // Mixed block
      '000001', // Single digit at the end
      '020000', // Single digit at the start
      '000042', // Standard zero-padded ID
      '050050', // Symmetrical zeros
    ];

    const Duration delay = Duration(milliseconds: 10);

    int totalExpectedLength = 0;
    int totalActualLength = 0;
    int exactMatches = 0;

    for (int i = 0; i < scenarios.length; i++) {
      final targetCode = scenarios[i];

      // Tap CLEAR to ensure a fresh state before each run
      await tester.tap(find.text('CLEAR'));
      await tester.pump();

      // Rapid-fire input at 100ms per keystroke
      for (int j = 0; j < targetCode.length; j++) {
        final digit = targetCode[j];
        await tester.tap(find.text(digit));
        await tester.pump(delay);
      }

      // Read the controller state directly from the mounted FastNumpad widget
      final numpad = tester.widget<FastNumpad>(find.byType(FastNumpad));
      final result = numpad.controller.text;

      totalExpectedLength += targetCode.length;
      totalActualLength += result.length;

      // Log the individual outcome
      if (result == targetCode) {
        exactMatches++;
        debugPrint('Scenario ${i + 1} ($targetCode): PASS');
      } else {
        debugPrint(
          'Scenario ${i + 1} ($targetCode): FAIL (Expected: "$targetCode", Got: "$result")',
        );
      }

      // Tap ENTER to trigger your debugPrint payload and clear the controller
      await tester.tap(find.text('ENTER'));
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Trigger one intentional error at the end to verify the red flashing UI
    await tester.tap(
      find.text('ENTER'),
    ); // Controller is empty, should trigger error
    await tester.pump(
      const Duration(milliseconds: 100),
    ); // Advance enough to see the red flash

    debugPrint('\n--- MAIN APP UI BENCHMARK ---');
    debugPrint(
      'Perfect Matches           : $exactMatches / ${scenarios.length}',
    );
    debugPrint('Total Characters Expected : $totalExpectedLength');
    debugPrint('Total Characters Captured : $totalActualLength');
    debugPrint('-----------------------------\n');

    await Future.delayed(const Duration(seconds: 1));

    // The test officially fails if the physical device dropped even a single input
    expect(
      exactMatches,
      scenarios.length,
      reason: 'The physical device dropped inputs during the live UI test!',
    );
  });
}
