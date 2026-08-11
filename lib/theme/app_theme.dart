import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Two fixed themes, applied per-screen (not tied to system dark
/// mode) — matches the design where some screens (Map, Ride Summary)
/// use a light surface and others (Profile, Game, Recording) use a
/// dark one.
class AppTheme {
  AppTheme._();

  static ThemeData get dark => _build(
    background: AppColors.black,
    surface: AppColors.secondaryBlack,
    onBackground: AppColors.white,
    brightness: Brightness.dark,
  );

  static ThemeData get light => _build(
    background: AppColors.white,
    surface: Colors.white,
    onBackground: AppColors.black,
    brightness: Brightness.light,
  );

  static ThemeData _build({
    required Color background,
    required Color surface,
    required Color onBackground,
    required Brightness brightness,
  }) {
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.yellow,
        onPrimary: AppColors.black,
        secondary: AppColors.yellow,
        onSecondary: AppColors.black,
        error: AppColors.danger,
        onError: AppColors.white,
        surface: surface,
        onSurface: onBackground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onBackground,
        elevation: 0,
        titleTextStyle: AppTypography.heading(
          color: onBackground,
          fontSize: 20,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.display(color: onBackground, fontSize: 48),
        headlineMedium: AppTypography.heading(
          color: onBackground,
          fontSize: 24,
        ),
        bodyLarge: AppTypography.body(color: onBackground, fontSize: 16),
        bodyMedium: AppTypography.body(color: onBackground, fontSize: 14),
        labelSmall: AppTypography.label(color: onBackground),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow,
          foregroundColor: AppColors.black,
          textStyle: AppTypography.body(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
