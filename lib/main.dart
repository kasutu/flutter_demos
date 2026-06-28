import 'package:flutter/material.dart';
import 'package:flutter_demos/numpad/pin_entry_form.dart';
import 'package:flutter_demos/ui/button.dart';

// Global notifier to manage the active ThemeMode
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() {
  runApp(const MyApp());
}

/// Custom ThemeExtension to host non-standard industrial color tokens
@immutable
class IndustrialColors extends ThemeExtension<IndustrialColors> {
  final Color good;
  final Color onGood;
  final Color warning;
  final Color onWarning;
  final Color input; // 1. Added explicit input color slot

  const IndustrialColors({
    required this.good,
    required this.onGood,
    required this.warning,
    required this.onWarning,
    required this.input,
  });

  @override
  IndustrialColors copyWith({
    Color? good,
    Color? onGood,
    Color? warning,
    Color? onWarning,
    Color? input,
  }) {
    return IndustrialColors(
      good: good ?? this.good,
      onGood: onGood ?? this.onGood,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      input: input ?? this.input,
    );
  }

  @override
  IndustrialColors lerp(ThemeExtension<IndustrialColors>? other, double t) {
    if (other is! IndustrialColors) return this;
    return IndustrialColors(
      good: Color.lerp(good, other.good, t)!,
      onGood: Color.lerp(onGood, other.onGood, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      input: Color.lerp(input, other.input, t)!,
    );
  }
}

extension IndustrialThemeOnContext on BuildContext {
  IndustrialColors get industrialColors =>
      Theme.of(this).extension<IndustrialColors>()!;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentThemeMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: currentThemeMode,

          // Light Theme: Generated from your :root OKLCH design tokens
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: const Color(0xFFFEFEFE),
            colorScheme: const ColorScheme.light(
              surface: Color(0xFFFEFEFE),
              onSurface: Color(0xFF0B0A09),
              primary: Color(0xFF1B1817),
              onPrimary: Color(0xFFFAFAF9),
              secondary: Color(0xFFF5F5F4),
              onSecondary: Color(0xFF1B1817),
              error: Color(0xFFE7000A),
              outlineVariant: Color(0xFFE7E4E3), // --border
            ),
            // Global style rule for any standard form fields
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: Color(
                0xFFE7E4E3,
              ), // --input: oklch(0.923 0.003 48.717)
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE7E4E3)),
                borderRadius: BorderRadius.zero,
              ),
            ),
            extensions: const [
              IndustrialColors(
                good: Color(0xFF16A34A),
                onGood: Color(0xFFFFFFFF),
                warning: Color(0xFFD97706),
                onWarning: Color(0xFFFFFFFF),
                input: Color(0xFFE7E4E3), // Light text field base
              ),
            ],
          ),

          // Dark Theme: Generated from your .dark OKLCH design tokens
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF0B0A09),
            colorScheme: const ColorScheme.dark(
              surface: Color(0xFF1B1817),
              onSurface: Color(0xFFFAFAF9),
              primary: Color(0xFFE7E4E3),
              onPrimary: Color(0xFF1B1817),
              secondary: Color(0xFF292423),
              onSecondary: Color(0xFFFAFAF9),
              error: Color(0xFFFF6366),
              outlineVariant: Color(0x1AFFFFFF), // --border: 10% white overlay
            ),
            // Global style rule for any dark form fields
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: Color(0x26FFFFFF), // --input: oklch(1 0 0 / 15%)
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0x1AFFFFFF)),
                borderRadius: BorderRadius.zero,
              ),
            ),
            extensions: const [
              IndustrialColors(
                good: Color(0xFF22C55E),
                onGood: Color(0xFF0B0A09),
                warning: Color(0xFFEAB308),
                onWarning: Color(0xFF0B0A09),
                input: Color(
                  0x26FFFFFF,
                ), // Dark text field base (15% white opacity)
              ),
            ],
          ),
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

                Row(
                  spacing: 16,
                  children: [
                    Button(
                      title: 'Do something',
                      onTap: () => debugPrint('something pressed'),
                    ),
                    Button(
                      title: 'Execute',
                      icon: Icons.play_arrow,
                      onTap: () => debugPrint('Execute pressed'),
                      accentColor: theme.colorScheme.primary,
                    ),
                    Button(
                      title: 'Abort',
                      icon: Icons.stop,
                      onTap: () => debugPrint('Abort pressed'),
                      accentColor: theme.colorScheme.error,
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
