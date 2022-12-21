import 'dart:io';

import 'package:flutter/material.dart';
import 'package:piwigo_ng/services/preferences_service.dart';

class LocaleNotifier extends ChangeNotifier {
  final String key = 'LOCALE';
  late Locale _locale;

  LocaleNotifier() {
    _locale = Locale('en');
    _loadFromPrefs();
  }

  Locale get locale => _locale;

  changeLocale(locale) {
    _locale = locale;
    _saveToPrefs();
    notifyListeners();
  }

  _loadFromPrefs() {
    _locale = Locale(appPreferences.getString(key) ?? Platform.localeName.substring(0, 1));
    notifyListeners();
  }

  _saveToPrefs() {
    appPreferences.setString(key, _locale.languageCode);
  }
}
