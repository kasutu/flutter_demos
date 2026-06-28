// lib/theme/industrial_colors.dart
import 'package:flutter/material.dart';

@immutable
class IndustrialColors extends ThemeExtension<IndustrialColors> {
  final Color good;
  final Color onGood;
  final Color warning;
  final Color onWarning;
  final Color input;

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

/// Global shortcut provider
extension IndustrialThemeOnContext on BuildContext {
  IndustrialColors get industrialColors =>
      Theme.of(this).extension<IndustrialColors>()!;
}
