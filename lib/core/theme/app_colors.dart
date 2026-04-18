import 'package:flutter/material.dart';

/// "Luminescent Vault" palette.
/// All sectioning is done with tonal shifts between these surfaces — never
/// with 1px borders.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF98CBFF);
  static const Color primaryContainer = Color(0xFF1E88FF);
  static const Color onPrimary = Color(0xFF0A1A33);

  // Background & surfaces (deepest → closest)
  static const Color background = Color(0xFF0B1326);
  static const Color surfaceDim = Color(0xFF0B1326);
  static const Color surface = Color(0xFF0E182F);
  static const Color surfaceContainerLowest = Color(0xFF0A1124);
  static const Color surfaceContainerLow = Color(0xFF111C37);
  static const Color surfaceContainer = Color(0xFF16223F);
  static const Color surfaceContainerHigh = Color(0xFF1A2947);
  static const Color surfaceContainerHighest = Color(0xFF1F3054);
  static const Color surfaceBright = Color(0xFF263A63);

  // Content
  static const Color onSurface = Color(0xFFF2F5FB);
  static const Color onSurfaceVariant = Color(0xFF9AA8C4);
  static const Color outlineVariant = Color(0xFF2C3E63);

  // Shadow (tinted navy, not black)
  static const Color ambientShadow = Color(0xFF060E20);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFBFE0FF), Color(0xFF37A7FF)],
  );
}
