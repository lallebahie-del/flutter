import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;
  String get code => _locale.languageCode;

  AppLanguage() {
    _loadLanguage();
  }

  // 🔹 Charger la langue sauvegardée
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('languageCode') ?? 'fr';
    _locale = Locale(code);
    notifyListeners();
  }

  // 🔹 Changer + sauvegarder la langue
  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();

    if (_locale.languageCode == 'fr') {
      _locale = const Locale('ar');
      await prefs.setString('languageCode', 'ar');
    } else {
      _locale = const Locale('fr');
      await prefs.setString('languageCode', 'fr');
    }

    notifyListeners();
  }
}
