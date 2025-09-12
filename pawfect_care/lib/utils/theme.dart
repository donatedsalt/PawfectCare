// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0D1C5A);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFF32C48D);
  static const Color onSecondary = Color(0xFFFFFFFF);

  static const Color tertiary = Color(0xFF7B3B51);
  static const Color onTertiary = Color(0xFFFFFFFF);

  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color onBackgroundLight = Color(0xFF333333);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF333333);

  static const Color backgroundDark = Color(0xFF121212);
  static const Color onBackgroundDark = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);

  static const Color outlineLight = Color(0xFF7B767E);
  static const Color outlineDark = Color(0xFF908E96);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
}

final lightColorScheme = const ColorScheme(
  brightness: Brightness.light,

  // Primary brand colors
  primary: AppColors.primary,
  onPrimary: AppColors.onPrimary,
  primaryContainer: Color(0xFFD6E3FF),
  onPrimaryContainer: AppColors.primary,

  // Secondary brand colors
  secondary: AppColors.secondary,
  onSecondary: AppColors.onSecondary,
  secondaryContainer: Color(0xFFABF3CC),
  onSecondaryContainer: Color(0xFF002113),

  // Tertiary accent colors
  tertiary: AppColors.tertiary,
  onTertiary: AppColors.onTertiary,
  tertiaryContainer: Color(0xFFFFD9E2),
  onTertiaryContainer: Color(0xFF2E111A),

  // Backgrounds and surfaces
  background: AppColors.backgroundLight,
  onBackground: AppColors.onBackgroundLight,
  surface: AppColors.surfaceLight,
  onSurface: AppColors.onSurfaceLight,

  // Error colors
  error: AppColors.error,
  onError: AppColors.onError,
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),

  // Other essential colors
  outline: AppColors.outlineLight,
  surfaceVariant: Color(0xFFE0E2EC),
  onSurfaceVariant: Color(0xFF44474E),
);

final darkColorScheme = const ColorScheme(
  brightness: Brightness.dark,

  // Primary brand colors
  primary: AppColors.primary,
  onPrimary: AppColors.onPrimary,
  primaryContainer: Color(0xFF3F558A),
  onPrimaryContainer: AppColors.onPrimary,

  // Secondary brand colors
  secondary: AppColors.secondary,
  onSecondary: AppColors.onSecondary,
  secondaryContainer: Color(0xFF194D31),
  onSecondaryContainer: AppColors.onSecondary,

  // Tertiary accent colors
  tertiary: AppColors.tertiary,
  onTertiary: AppColors.onTertiary,
  tertiaryContainer: Color(0xFF5D2436),
  onTertiaryContainer: AppColors.onTertiary,

  // Backgrounds and surfaces
  background: AppColors.backgroundDark,
  onBackground: AppColors.onBackgroundDark,
  surface: AppColors.surfaceDark,
  onSurface: AppColors.onSurfaceDark,

  // Error colors
  error: AppColors.error,
  onError: AppColors.onError,
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFBA1A1A),

  // Other essential colors
  outline: AppColors.outlineDark,
  surfaceVariant: Color(0xFF44474E),
  onSurfaceVariant: Color(0xFFC4C6D0),
);

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: lightColorScheme.primary,
      foregroundColor: lightColorScheme.onPrimary,
      titleTextStyle: TextStyle(
        color: lightColorScheme.onPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: lightColorScheme.primary,
      indicatorColor: Colors.white24,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: lightColorScheme.onPrimary, size: 28);
        }
        return IconThemeData(color: lightColorScheme.onPrimary, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            color: lightColorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          );
        }
        return TextStyle(color: lightColorScheme.onPrimary);
      }),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lightColorScheme.primary,
      foregroundColor: lightColorScheme.onPrimary,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(lightColorScheme.primary),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme.primary,
      foregroundColor: darkColorScheme.onPrimary,
      titleTextStyle: TextStyle(
        color: darkColorScheme.onPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkColorScheme.primary,
      indicatorColor: Colors.white24,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: darkColorScheme.onPrimary, size: 28);
        }
        return IconThemeData(color: darkColorScheme.onPrimary, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            color: darkColorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          );
        }
        return TextStyle(color: darkColorScheme.onPrimary);
      }),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkColorScheme.primary,
      foregroundColor: darkColorScheme.onPrimary,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(darkColorScheme.primary),
      ),
    ),
  );
}
