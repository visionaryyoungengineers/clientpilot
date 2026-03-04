import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.secondaryForeground,
        surface: AppColors.card, // Cards/Sheets are White
        onSurface: AppColors.foreground,
        error: AppColors.destructive,
        onError: AppColors.destructiveForeground,
        tertiary: AppColors.accent,
        onTertiary: AppColors.accentForeground,
        surfaceContainerHighest: AppColors.muted, // For fills/inputs
        outlineVariant: AppColors.border,
      ),
      scaffoldBackgroundColor: AppColors.background, // Distinct off-white background
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.foreground),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.foreground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: AppColors.foreground,
        displayColor: AppColors.foreground,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0, // Elevations are handled manually using CSS shadows mostly
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18), // var(--radius)
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent, // Handled inside widgets
        elevation: 0,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.secondaryDark,
        onSecondary: AppColors.secondaryForeground,
        surface: AppColors.cardDark,
        onSurface: AppColors.foregroundDark,
        error: AppColors.destructive,
        onError: AppColors.destructiveForeground,
        tertiary: AppColors.accent,
        onTertiary: AppColors.accentForeground,
        surfaceContainerHighest: AppColors.mutedDark,
        outlineVariant: AppColors.borderDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.foregroundDark),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.foregroundDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.foregroundDark,
        displayColor: AppColors.foregroundDark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      useMaterial3: true,
    );
  }
}
