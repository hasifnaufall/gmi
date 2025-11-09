import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  bool _isDarkMode = false;
  bool _isInitialized = false;
  bool _isLoading = false;

  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  // Static helper to get theme manager from context
  static ThemeManager of(BuildContext context, {bool listen = true}) {
    return Provider.of<ThemeManager>(context, listen: listen);
  }

  ThemeManager() {
    // Don't load theme in constructor - do it lazily
    _loadThemeAsync();
  }

  void _loadThemeAsync() {
    if (_isLoading) return;
    _isLoading = true;

    Future.microtask(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedTheme = prefs.getBool(_themeKey) ?? false;
        if (_isDarkMode != savedTheme) {
          _isDarkMode = savedTheme;
          _isInitialized = true;
          notifyListeners();
        } else {
          _isInitialized = true;
        }
      } catch (e) {
        print('Error loading theme: $e');
        _isInitialized = true;
      } finally {
        _isLoading = false;
      }
    });
  }

  Future<void> toggleTheme() async {
    try {
      _isDarkMode = !_isDarkMode;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      print('Error toggling theme: $e');
    }
  }

  // Light Mode Colors
  static const Color lightPrimary = Color(0xFF69D3E4);
  static const Color lightSecondary = Color(0xFF4FC3E4);
  static const Color lightBackground = Color(0xFFCFFFF7);
  static const Color lightCardBackground = Colors.white;
  static const Color lightTextPrimary = Color(0xFF2D5263);
  static const Color lightTextSecondary = Color(0xFF69D3E4);

  // Dark Mode Colors (from color palette image)
  static const Color darkPrimary = Color(0xFFD23232); // Red accent
  static const Color darkSecondary = Color(0xFF8B1F1F); // Dark red
  static const Color darkBackground = Color(0xFF1C1C1E); // Almost black
  static const Color darkCardBackground = Color(0xFF8E8E93); // Grey
  static const Color darkTextPrimary = Color(0xFFE8E8E8); // Light grey/white
  static const Color darkTextSecondary = Color(0xFFD23232); // Red for accents
  static const Color darkSurface = Color(0xFF636366); // Medium grey

  // Gradient Colors
  LinearGradient get primaryGradient => _isDarkMode
      ? const LinearGradient(
          colors: [Color(0xFF8B1F1F), Color(0xFFD23232)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  LinearGradient get backgroundGradient => _isDarkMode
      ? const LinearGradient(
          colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )
      : const LinearGradient(
          colors: [Color(0xFFCFFFF7), Color(0xFFE6FFFA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

  Color get backgroundColor => _isDarkMode ? darkBackground : lightBackground;
  Color get cardBackground =>
      _isDarkMode ? darkCardBackground : lightCardBackground;
  Color get textPrimary => _isDarkMode ? darkTextPrimary : lightTextPrimary;
  Color get textSecondary =>
      _isDarkMode ? darkTextSecondary : lightTextSecondary;
  Color get primary => _isDarkMode ? darkPrimary : lightPrimary;
  Color get secondary => _isDarkMode ? darkSecondary : lightSecondary;
  Color get surface => _isDarkMode ? darkSurface : Colors.white;

  ThemeData get themeData => ThemeData(
    brightness: _isDarkMode ? Brightness.dark : Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardBackground,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textPrimary),
      titleLarge: TextStyle(color: textPrimary),
    ),
  );
}
