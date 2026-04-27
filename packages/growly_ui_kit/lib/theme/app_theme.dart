import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Brand colors
  static const Color growlyGreen = Color(0xFF2ECC71);
  static const Color growlyBlue = Color(0xFF3498DB);
  static const Color growlyPurple = Color(0xFF9B59B6);
  static const Color growlyOrange = Color(0xFFF39C12);
  static const Color growlyRed = Color(0xFFE74C3C);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: growlyGreen,
        brightness: Brightness.light,
      ),
      fontFamily: 'Nunito',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: growlyGreen,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Nunito',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  // Subject colors for learning hub
  static Color getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'reading':
        return const Color(0xFF3498DB);
      case 'math':
        return const Color(0xFF2ECC71);
      case 'science':
        return const Color(0xFF9B59B6);
      case 'creative':
        return const Color(0xFFF39C12);
      case 'language':
        return const Color(0xFFE74C3C);
      default:
        return growlyGreen;
    }
  }

  // Badge colors
  static Color getBadgeColor(String badgeType) {
    switch (badgeType.toLowerCase()) {
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'bronze':
        return const Color(0xFFCD7F32);
      default:
        return growlyGreen;
    }
  }
}

extension ThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
}