import 'package:flutter/material.dart';

abstract class SettingsRepository {
  const SettingsRepository();

  ThemeMode getThemeMode();
}
