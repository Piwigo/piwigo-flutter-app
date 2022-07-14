import 'dart:io';

import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/API.dart';


class LocaleNotifier extends ChangeNotifier {
  final String key = "locale";
  Locale _locale;
  Locale get locale => _locale;

  LocaleNotifier() {
    _locale = Locale('en');
    _loadFromPrefs();
  }

  changeLocale(locale){
    _locale = locale;
    _saveToPrefs();
    notifyListeners();
  }

  _loadFromPrefs() {
    _locale = Locale(API.prefs.getString(key) ?? Platform.localeName.substring(0, 1));
    notifyListeners();
  }

  _saveToPrefs() {
    API.prefs.setString(key, _locale.languageCode);
  }
}
