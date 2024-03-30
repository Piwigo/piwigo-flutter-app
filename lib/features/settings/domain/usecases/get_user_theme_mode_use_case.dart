import 'package:flutter/material.dart';
import 'package:piwigo_ng/features/settings/data/repositories/settings_repository.impl.dart';
import 'package:piwigo_ng/features/settings/domain/repositories/settings_repository.dart';

class GetUserThemeModeUseCase {
  const GetUserThemeModeUseCase();

  final SettingsRepository _repository = const SettingsRepositoryImpl();

  ThemeMode execute() => _repository.getThemeMode();
}
