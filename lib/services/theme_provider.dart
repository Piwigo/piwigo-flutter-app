import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  static const String themeKey = 'THEME';
  bool _isDark;
  bool get isDark => _isDark;

  ThemeNotifier() : _isDark = ThemeMode.system == ThemeMode.dark {
    getTheme();
  }

  toggleTheme() {
    _isDark = !_isDark;
    setTheme();
    notifyListeners();
  }

  setTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(themeKey, _isDark);
  }

  getTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _isDark = sharedPreferences.getBool(themeKey) ??
        (ThemeMode.system == ThemeMode.dark);
    notifyListeners();
  }
}
