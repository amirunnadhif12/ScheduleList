import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0F766E); // Deep Teal
  static const Color primaryDark = Color(0xFF0B5E58);
  static const Color accent = Color(0xFFF59E0B); // Golden Amber
  static const Color success = Color(0xFF22C55E); // Emerald Green
  static const Color overdue = Color(0xFFEF4444); // Soft Red
  static const Color background = Color(0xFFF9FAFB); // Soft White
  static const Color text = Color(0xFF1F2937); // Charcoal Dark

  // light variants (using opacity)
  static Color primaryLight([double o = 0.1]) => primary.withOpacity(o);
  static Color successLight([double o = 0.12]) => success.withOpacity(o);
  static Color accentLight([double o = 0.12]) => accent.withOpacity(o);
  static Color overdueLight([double o = 0.12]) => overdue.withOpacity(o);
}

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.text),
    bodyMedium: TextStyle(color: AppColors.text),
    bodySmall: TextStyle(color: AppColors.text),
  ),
);
