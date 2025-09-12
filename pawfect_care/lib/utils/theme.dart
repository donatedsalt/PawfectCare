import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0D1C5A);
  static const Color accent = Color(0xFF32C48D);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF333333);
  static const Color textLight = Color(0xFFFFFFFF);
}

final customColorScheme = ColorScheme.fromSeed(
  seedColor: AppColors.primary,
).copyWith(secondary: AppColors.accent);

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: customColorScheme,
    appBarTheme: AppBarThemeData(
      backgroundColor: customColorScheme.primary,
      foregroundColor: customColorScheme.onPrimary,

      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: customColorScheme.onPrimary,
      ),
    ),
    scaffoldBackgroundColor: customColorScheme.primaryFixed,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: customColorScheme.primary,
      indicatorColor: customColorScheme.onPrimary.withAlpha(40),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: customColorScheme.onPrimary, size: 28);
        }
        return IconThemeData(color: customColorScheme.onPrimary, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            color: customColorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          );
        }
        return TextStyle(color: customColorScheme.onPrimary);
      }),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: customColorScheme.primary,
      foregroundColor: customColorScheme.onPrimary,
    ),
  );
}
