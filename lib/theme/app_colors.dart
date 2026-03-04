import 'package:flutter/material.dart';

class AppColors {
  // Base Surface Colors (Light)
  static final Color background = HSLColor.fromAHSL(1.0, 210.0, 0.33, 0.97).toColor();
  static final Color foreground = HSLColor.fromAHSL(1.0, 220.0, 0.20, 0.10).toColor();
  static final Color card = HSLColor.fromAHSL(1.0, 0.0, 0.0, 1.0).toColor();
  static final Color cardForeground = HSLColor.fromAHSL(1.0, 220.0, 0.20, 0.10).toColor();
  
  // Base Surface Colors (Dark)
  static final Color backgroundDark = HSLColor.fromAHSL(1.0, 220.0, 0.24, 0.08).toColor();
  static final Color foregroundDark = HSLColor.fromAHSL(1.0, 210.0, 0.18, 0.95).toColor();
  static final Color cardDark = HSLColor.fromAHSL(1.0, 220.0, 0.22, 0.12).toColor();
  static final Color cardForegroundDark = HSLColor.fromAHSL(1.0, 210.0, 0.18, 0.95).toColor();

  // Brand Palette
  static final Color primary = HSLColor.fromAHSL(1.0, 187.0, 0.72, 0.42).toColor(); // cp-teal
  static final Color primaryDark = HSLColor.fromAHSL(1.0, 187.0, 0.64, 0.50).toColor();
  static final Color primaryForeground = Colors.white;

  static final Color secondary = HSLColor.fromAHSL(1.0, 210.0, 0.28, 0.95).toColor();
  static final Color secondaryDark = HSLColor.fromAHSL(1.0, 220.0, 0.18, 0.16).toColor();
  static final Color secondaryForeground = HSLColor.fromAHSL(1.0, 215.0, 0.20, 0.22).toColor();
  
  static final Color muted = HSLColor.fromAHSL(1.0, 210.0, 0.22, 0.93).toColor();
  static final Color mutedDark = HSLColor.fromAHSL(1.0, 220.0, 0.18, 0.16).toColor();
  static final Color mutedForeground = HSLColor.fromAHSL(1.0, 215.0, 0.14, 0.50).toColor();
  static final Color mutedForegroundDark = HSLColor.fromAHSL(1.0, 215.0, 0.14, 0.56).toColor();

  static final Color accent = HSLColor.fromAHSL(1.0, 24.0, 0.92, 0.58).toColor(); // Coral
  static final Color accentForeground = Colors.white;

  static final Color destructive = HSLColor.fromAHSL(1.0, 0.0, 0.68, 0.52).toColor();
  static final Color destructiveForeground = Colors.white;

  // Borders & Inputs
  static final Color border = HSLColor.fromAHSL(1.0, 210.0, 0.18, 0.92).toColor();
  static final Color borderDark = HSLColor.fromAHSL(1.0, 220.0, 0.18, 0.18).toColor();
  static final Color input = border;
  static final Color inputDark = borderDark;

  // Glass & Borders
  static final Color glassBg = HSLColor.fromAHSL(0.72, 0.0, 0.0, 1.0).toColor();
  static final Color glassBorder = HSLColor.fromAHSL(0.10, 0.0, 0.0, 1.0).toColor();
  static final Color glassStrongBg = HSLColor.fromAHSL(0.88, 0.0, 0.0, 1.0).toColor();

  // Gradients
  static const LinearGradient gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2EA3D2), // approximate HSL(200 68% 52%)
      Color(0xFF1DB8C8), // approximate HSL(187 72% 42%)
    ],
  );

  static const LinearGradient gradientHeroSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5AB4D9), // approximate HSL(200 60% 58%)
      Color(0xFF2FBDCD), // approximate HSL(187 64% 50%)
    ],
  );

  static const LinearGradient gradientCoral = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFC7753), // HSL(12 90% 60%)
      Color(0xFFDF416C), // HSL(346 72% 56%)
    ],
  );
  
  static const LinearGradient gradientCta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF31AF76), // HSL(158 56% 44%)
      Color(0xFF339980), // HSL(168 50% 40%)
    ],
  );

  // Status Colors (Matches CSS cp-amber / cp-green)
  static final Color amber = HSLColor.fromAHSL(1.0, 38.0, 0.92, 0.50).toColor();
  static final Color green = HSLColor.fromAHSL(1.0, 158.0, 0.56, 0.44).toColor();
}
