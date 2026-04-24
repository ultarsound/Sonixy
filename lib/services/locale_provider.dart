import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('language') ?? 'ar';
    _locale = Locale(lang);
    notifyListeners();
  }

  Future<void> toggleLocale() async {
    final prefs = await SharedPreferences.getInstance();
    if (_locale.languageCode == 'ar') {
      _locale = const Locale('en');
      await prefs.setString('language', 'en');
    } else {
      _locale = const Locale('ar');
      await prefs.setString('language', 'ar');
    }
    notifyListeners();
  }

  bool get isArabic => _locale.languageCode == 'ar';
}
