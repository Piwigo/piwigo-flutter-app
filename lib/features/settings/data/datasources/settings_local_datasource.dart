import 'package:flutter/material.dart';

abstract class SettingsLocalDatasource {
  const SettingsLocalDatasource();

  ThemeMode getThemeMode();
}
