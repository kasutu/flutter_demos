// lib/theme/industrial_theme.dart
import 'package:flutter/material.dart';
import 'industrial_colors.dart';

abstract class IndustrialTheme {
  /// Portable Light Configuration
  static ThemeData get light {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color(0xFFFEFEFE),
      colorScheme: const ColorScheme.light(
        surface: Color(0xFFFEFEFE),
        onSurface: Color(0xFF0B0A09),
        primary: Color(0xFF1B1817),
        onPrimary: Color(0xFFFAFAF9),
        secondary: Color(0xFFF5F5F4),
        onSecondary: Color(0xFF1B1817),
        error: Color(0xFFE7000A),
        outlineVariant: Color(0xFFE7E4E3),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFE7E4E3),
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
          input: Color(0xFFE7E4E3),
        ),
      ],
    );
  }

  /// Portable Dark Configuration
  static ThemeData get dark {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF0B0A09),
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF1B1817),
        onSurface: Color(0xFFFAFAF9),
        primary: Color(0xFFE7E4E3),
        onPrimary: Color(0xFF1B1817),
        secondary: Color(0xFF292423),
        onSecondary: Color(0xFFFAFAF9),
        error: Color(0xFFFF6366),
        outlineVariant: Color(0x1AFFFFFF),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0x26FFFFFF),
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
          input: Color(0x26FFFFFF),
        ),
      ],
    );
  }
}
