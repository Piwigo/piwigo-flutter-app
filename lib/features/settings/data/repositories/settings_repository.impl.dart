import 'package:flutter/material.dart';
import 'package:piwigo_ng/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:piwigo_ng/features/settings/data/datasources/settings_local_datasource.impl.dart';
import 'package:piwigo_ng/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl extends SettingsRepository {
  const SettingsRepositoryImpl();

  final SettingsLocalDatasource _localDatasource = const SettingsLocalDatasourceImpl();

  @override
  ThemeMode getThemeMode() => _localDatasource.getThemeMode();
}
