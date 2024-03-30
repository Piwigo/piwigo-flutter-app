import 'package:flutter/material.dart';
import 'package:piwigo_ng/core/data/datasources/local/preferences_datasource.dart';
import 'package:piwigo_ng/core/extensions/theme_mode_extension.dart';
import 'package:piwigo_ng/core/utils/constants/local_key_constants.dart';
import 'package:piwigo_ng/features/settings/data/datasources/settings_local_datasource.dart';

class SettingsLocalDatasourceImpl extends SettingsLocalDatasource with AppPreferencesMixin {
  const SettingsLocalDatasourceImpl();

  @override
  ThemeMode getThemeMode() => themeModeFromJson(prefs.instance.getString(LocalKeyConstants.themeKey));
}
