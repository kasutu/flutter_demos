import 'package:flutter/material.dart';
import 'package:flutter_demos/numpad/pin_entry_form.dart';
import 'package:flutter_demos/ui/button.dart';
import 'theme/industrial_theme.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentThemeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: currentThemeMode,

          // REUSED HERE: Pulls directly from the theme registry
          theme: IndustrialTheme.light,
          darkTheme: IndustrialTheme.dark,

          home: const IndustrialTerminal(),
        );
      },
    );
  }
}

class IndustrialTerminal extends StatelessWidget {
  const IndustrialTerminal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 24,
              children: [
                PinEntryForm(
                  validator: (code) => code == '123456',
                  onSubmit: (code) =>
                      debugPrint('Executed payload value: $code'),
                  onCancel: () => debugPrint('Transaction cancelled.'),
                ),

                Column(
                  spacing: 16, // Requires Flutter 3.22+
                  children: [
                    // 1. "HUG" (Default) - Safely wraps its text with the standard 42px padding.
                    PrimaryButton(title: 'Execute', onTap: () {}),

                    // 2. "FILL" - Inside a Row, Expanded naturally fills available space!
                    // (Note: Removed `flex: 0` as Expanded defaults to flex 1 to actually fill).
                    Expanded(
                      flex: 0,
                      child: OutlineButton(title: 'Diagnostic', onTap: () {}),
                    ),

                    // 3. "FIXED" - Locks to precise dimensions.
                    // (Note: Width is fixed to 120, but height remains locked to your standard 42px).
                    SecondaryButton(title: 'Stop', width: 120, onTap: () {}),

                    // 4. "SCALED" - Adjusting inner visuals.
                    // (Note: We removed the custom fontSize and iconSize properties in the
                    // refactor to enforce your 24px/32px rule. It now renders at the standard size).
                    GhostButton(
                      title: 'Task',
                      icon: Icons.search,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          themeNotifier.value = themeNotifier.value == ThemeMode.dark
              ? ThemeMode.light
              : ThemeMode.dark;
        },
        backgroundColor: theme.colorScheme.primary,
        child: Icon(
          themeNotifier.value == ThemeMode.dark
              ? Icons.light_mode
              : Icons.dark_mode,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}
