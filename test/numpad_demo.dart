import 'package:flutter/material.dart';
import 'package:flutter_demos/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumpadDemo Widget Tests', () {
    // Helper function to load the widget into the tester
    Future<void> pumpNumpadScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NumpadDemo(), // The wrapper we built with the ValueNotifier
          ),
        ),
      );
    }

    testWidgets('Renders initial state correctly', (WidgetTester tester) async {
      await pumpNumpadScreen(tester);

      // Verify the initial display is '0'
      expect(find.text('0'), findsOneWidget);

      // Verify all digits exist on the screen
      for (int i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }

      // Verify the backspace icon exists
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });

    testWidgets('Tapping digits updates the display correctly', (
      WidgetTester tester,
    ) async {
      await pumpNumpadScreen(tester);

      // Tap '1', '5', '9'
      await tester.tap(find.text('1'));
      await tester.pump(); // Let the ValueNotifier trigger the UI update

      await tester.tap(find.text('5'));
      await tester.pump();

      await tester.tap(find.text('9'));
      await tester.pump();

      // The screen should no longer show '0', it should show '159'
      expect(find.text('0'), findsNothing);
      expect(find.text('159'), findsOneWidget);
    });

    testWidgets('Backspace removes characters and respects empty state', (
      WidgetTester tester,
    ) async {
      await pumpNumpadScreen(tester);

      // Type '42'
      await tester.tap(find.text('4'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();

      expect(find.text('42'), findsOneWidget);

      // Tap backspace once
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      // Should now be '4'
      expect(find.text('4'), findsOneWidget);

      // Tap backspace again
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      // String is empty, so our UI logic should fall back to showing '0'
      expect(find.text('0'), findsOneWidget);

      // Tap backspace on an empty string to ensure it doesn't crash
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      expect(
        tester.takeException(),
        isNull,
      ); // Ensures no out-of-bounds error occurred
    });

    testWidgets('Enforces the 12-character maximum limit', (
      WidgetTester tester,
    ) async {
      await pumpNumpadScreen(tester);

      // Rapidly tap '7' thirteen times
      for (int i = 0; i < 13; i++) {
        await tester.tap(find.text('7'));
        // We can group pumps together for performance in tests,
        // or pump after every tap.
      }
      await tester.pumpAndSettle();

      // It should only register 12 sevens.
      expect(find.text('777777777777'), findsOneWidget);
      expect(find.text('7777777777777'), findsNothing); // 13th tap ignored
    });
  });
}
