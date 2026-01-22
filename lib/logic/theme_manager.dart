import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  freshMint,
  oceanBreeze,
  sunrisePeach,
  lavenderDream,
  skyBlue,
  roseGold,
}

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  AppTheme _currentTheme = AppTheme.freshMint;
  AppTheme get currentTheme => _currentTheme;

  // Fresh Light Theme Colors
  static const Map<AppTheme, ThemeColors> themes = {
    AppTheme.freshMint: ThemeColors(
      name: "Fresh Mint",
      gradientStart: Color(0xFFE8F5E9),
      gradientMiddle: Color(0xFFA5D6A7),
      gradientEnd: Color(0xFF66BB6A),
      accent: Color(0xFF2E7D32),
      gold: Color(0xFFFFB300),
    ),
    AppTheme.oceanBreeze: ThemeColors(
      name: "Ocean Breeze",
      gradientStart: Color(0xFFE0F7FA),
      gradientMiddle: Color(0xFF80DEEA),
      gradientEnd: Color(0xFF26C6DA),
      accent: Color(0xFF00838F),
      gold: Color(0xFFFFB300),
    ),
    AppTheme.sunrisePeach: ThemeColors(
      name: "Sunrise Peach",
      gradientStart: Color(0xFFFFFDE7),
      gradientMiddle: Color(0xFFFFE082),
      gradientEnd: Color(0xFFFFB74D),
      accent: Color(0xFFE65100),
      gold: Color(0xFFFFD700),
    ),
    AppTheme.lavenderDream: ThemeColors(
      name: "Lavender Dream",
      gradientStart: Color(0xFFF3E5F5),
      gradientMiddle: Color(0xFFCE93D8),
      gradientEnd: Color(0xFFBA68C8),
      accent: Color(0xFF7B1FA2),
      gold: Color(0xFFFFB300),
    ),
    AppTheme.skyBlue: ThemeColors(
      name: "Sky Blue",
      gradientStart: Color(0xFFE3F2FD),
      gradientMiddle: Color(0xFF90CAF9),
      gradientEnd: Color(0xFF42A5F5),
      accent: Color(0xFF1565C0),
      gold: Color(0xFFFFB300),
    ),
    AppTheme.roseGold: ThemeColors(
      name: "Rose Gold",
      gradientStart: Color(0xFFFCE4EC),
      gradientMiddle: Color(0xFFF48FB1),
      gradientEnd: Color(0xFFEC407A),
      accent: Color(0xFFC2185B),
      gold: Color(0xFFFFD700),
    ),
  };

  ThemeColors get colors => themes[_currentTheme]!;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('app_theme') ?? 0;
    _currentTheme = AppTheme.values[themeIndex];
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_theme', theme.index);
    notifyListeners();
  }
}

class ThemeColors {
  final String name;
  final Color gradientStart;
  final Color gradientMiddle;
  final Color gradientEnd;
  final Color accent;
  final Color gold;

  const ThemeColors({
    required this.name,
    required this.gradientStart,
    required this.gradientMiddle,
    required this.gradientEnd,
    required this.accent,
    required this.gold,
  });
}
