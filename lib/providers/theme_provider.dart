import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemeProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _darkModeKey = 'isDarkMode';
  bool _isDarkMode = false;

  ThemeProvider(this._prefs) {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  void _loadTheme() {
    _isDarkMode = _prefs.getBool(_darkModeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
}