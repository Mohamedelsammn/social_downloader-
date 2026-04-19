import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primaryLight = Color(0xFFD2BBFF);
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryContainer = Color(0xFF4C1D95);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Background & surfaces
  static const Color background = Color(0xFF000000);
  static const Color surfaceDim = Color(0xFF080808);
  static const Color surface = Color(0xFF111111);
  static const Color surfaceContainerLowest = Color(0xFF0A0A0A);
  static const Color surfaceContainerLow = Color(0xFF111111);
  static const Color surfaceContainer = Color(0xFF161616);
  static const Color surfaceContainerHigh = Color(0xFF1A1A1A);
  static const Color surfaceContainerHighest = Color(0xFF222222);
  static const Color surfaceBright = Color(0xFF2A2A2A);

  // Content
  static const Color onSurface = Color(0xFFE3E0F6);
  static const Color onSurfaceVariant = Color(0xFFCCC3D8);
  static const Color outlineVariant = Color(0x0DFFFFFF);

  // Shadow
  static const Color ambientShadow = Color(0xFF000000);
  static const Color primaryShadow = Color(0x4D7C3AED);

  // Status
  static const Color error = Color(0xFFFF8A8A);
  static const Color success = Color(0xFF4ADE80);

  // Platform colors
  static const Color facebookBlue = Color(0xFF2563EB);
  static const Color youtubeRed = Color(0xFFDC2626);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD2BBFF), Color(0xFF7C3AED)],
  );

  static const LinearGradient instagramGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [Color(0xFFFDE047), Color(0xFFEC4899), Color(0xFF8B5CF6)],
  );
}
