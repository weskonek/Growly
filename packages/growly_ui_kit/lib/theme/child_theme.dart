import 'package:flutter/material.dart';
import 'app_theme.dart';

class ChildTheme {
  ChildTheme._();

  // Larger touch targets for children
  static const double minButtonHeight = 56.0;
  static const double minButtonWidth = 48.0;
  static const double cardMinHeight = 100.0;
  static const double iconSizeLarge = 48.0;
  static const double iconSizeMedium = 36.0;

  // Border radius for child-friendly UI
  static const double borderRadiusLarge = 24.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusSmall = 12.0;

  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationFast = Duration(milliseconds: 150);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTheme.growlyGreen,
        brightness: Brightness.light,
        primary: AppTheme.growlyGreen,
        secondary: AppTheme.growlyBlue,
        surface: const Color(0xFFF5F5F5),
      ),
      fontFamily: 'Nunito',
      // Larger text for children
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
        bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 72,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(minButtonWidth, minButtonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(fontSize: 16),
      ),
      iconTheme: const IconThemeData(
        size: iconSizeMedium,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTheme.growlyGreen,
        brightness: Brightness.dark,
        primary: AppTheme.growlyGreen,
        secondary: AppTheme.growlyBlue,
        surface: const Color(0xFF1E1E1E),
      ),
      fontFamily: 'Nunito',
      textTheme: light.textTheme,
      appBarTheme: light.appBarTheme,
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        color: const Color(0xFF2D2D2D),
      ),
      elevatedButtonTheme: light.elevatedButtonTheme,
      inputDecorationTheme: light.inputDecorationTheme,
      iconTheme: const IconThemeData(
        size: iconSizeMedium,
      ),
    );
  }
}