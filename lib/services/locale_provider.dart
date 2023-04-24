import 'dart:io';

import 'package:flutter/material.dart';
import 'package:piwigo_ng/services/preferences_service.dart';

class LocaleNotifier extends ChangeNotifier {
  static final String key = 'LOCALE';
  late Locale _locale;

  LocaleNotifier() {
    _loadFromPrefs();
  }

  Locale get locale => _locale;

  changeLocale(locale) {
    _locale = locale;
    _saveToPrefs();
    notifyListeners();
  }

  _loadFromPrefs() {
    _locale = Locale(
        appPreferences.getString(key) ?? Platform.localeName.split('_').first);
    notifyListeners();
  }

  _saveToPrefs() {
    appPreferences.setString(key, _locale.languageCode);
  }
}
