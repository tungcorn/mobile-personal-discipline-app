import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _keyThemeMode = 'app_theme_mode_v1';
  final SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider(this._prefs) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadTheme() {
    final saved = _prefs.getString(_keyThemeMode);
    if (saved == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (saved == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    if (mode == ThemeMode.dark) {
      await _prefs.setString(_keyThemeMode, 'dark');
    } else if (mode == ThemeMode.light) {
      await _prefs.setString(_keyThemeMode, 'light');
    } else {
      await _prefs.setString(_keyThemeMode, 'system');
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}
