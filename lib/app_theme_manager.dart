import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  AppThemeManager() {
    _loadTheme();
  }

  // 🔹 Charger le thème sauvegardé
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('themeMode');

    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  // 🔹 Changer et sauvegarder le thème
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      await prefs.setString('themeMode', 'dark');
    } else {
      _themeMode = ThemeMode.light;
      await prefs.setString('themeMode', 'light');
    }

    notifyListeners();
  }
}
