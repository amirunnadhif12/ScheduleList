import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static bool _isDark = false;

  static void setDarkMode(bool value) => _isDark = value;

  // Primary colors — lebih cerah di dark mode untuk kontras
  static Color get primary => _isDark ? const Color(0xFF14B8A6) : const Color(0xFF0F766E);
  static Color get primaryDark => _isDark ? const Color(0xFF0F9688) : const Color(0xFF0B5E58);
  static Color get accent => _isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
  static Color get success => _isDark ? const Color(0xFF34D399) : const Color(0xFF22C55E);
  static Color get overdue => _isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);

  // Adaptive colors — high contrast dark
  static Color get background => _isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF9FAFB);
  static Color get surface => _isDark ? const Color(0xFF141414) : Colors.white;
  static Color get card => _isDark ? const Color(0xFF1A1A1A) : Colors.white;
  static Color get text => _isDark ? const Color(0xFFF5F5F5) : const Color(0xFF1F2937);
  static Color get textSecondary => _isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280);
  static Color get divider => _isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB);
  static Color get shadow => _isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.08);

  // light variants
  static Color primaryLight([double a = 0.1]) => primary.withValues(alpha: a);
  static Color successLight([double a = 0.12]) => success.withValues(alpha: a);
  static Color accentLight([double a = 0.12]) => accent.withValues(alpha: a);
  static Color overdueLight([double a = 0.12]) => overdue.withValues(alpha: a);

  // Adaptive grey replacements (untuk ganti Colors.grey[xxx])
  /// Replaces Colors.grey[200] / Colors.grey.shade200 — borders, dividers
  static Color get grey200 => _isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE5E7EB);
  /// Replaces Colors.grey[300] — light borders
  static Color get grey300 => _isDark ? const Color(0xFF444444) : const Color(0xFFD1D5DB);
  /// Replaces Colors.grey[400] — disabled icons
  static Color get grey400 => _isDark ? const Color(0xFF888888) : const Color(0xFF9CA3AF);
  /// Replaces Colors.grey[500] — secondary icons
  static Color get grey500 => _isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B7280);
  /// Replaces Colors.grey[600] — secondary text
  static Color get grey600 => _isDark ? const Color(0xFFBBBBBB) : const Color(0xFF4B5563);
}

// ── Theme Notifier ──
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  ThemeNotifier() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('dark_mode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    AppColors.setDarkMode(isDark);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final newIsDark = !isDark;
    _themeMode = newIsDark ? ThemeMode.dark : ThemeMode.light;
    AppColors.setDarkMode(newIsDark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', newIsDark);
    notifyListeners();
  }
}

// ── Light Theme ──
final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: const Color(0xFFF9FAFB),
  cardColor: Colors.white,
  appBarTheme: AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF1F2937)),
    bodyMedium: TextStyle(color: Color(0xFF1F2937)),
    bodySmall: TextStyle(color: Color(0xFF1F2937)),
  ),
);

// ── Dark Theme ──
final appDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF14B8A6),
    brightness: Brightness.dark,
    surface: const Color(0xFF0A0A0A),
  ),
  primaryColor: const Color(0xFF14B8A6),
  scaffoldBackgroundColor: const Color(0xFF0A0A0A),
  cardColor: const Color(0xFF1A1A1A),
  dialogBackgroundColor: const Color(0xFF1A1A1A),
  dividerColor: const Color(0xFF2A2A2A),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: Color(0xFF141414),
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFF5F5F5)),
    bodyMedium: TextStyle(color: Color(0xFFF5F5F5)),
    bodySmall: TextStyle(color: Color(0xFFB0B0B0)),
  ),
);
