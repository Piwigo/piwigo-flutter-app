import 'package:piwigo_ng/core/injector/injector.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesDatasource {
  const PreferencesDatasource();

  static final SharedPreferences _prefs = serviceLocator();

  SharedPreferences get instance => _prefs;
}

mixin AppPreferencesMixin {
  PreferencesDatasource get prefs => const PreferencesDatasource();
}
