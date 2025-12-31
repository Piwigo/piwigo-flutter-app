import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:piwigo_ng/app.dart';
import 'package:piwigo_ng/data/services/api/api_client.dart';
import 'package:piwigo_ng/data/services/local/auto_upload_manager.dart';
import 'package:piwigo_ng/data/services/local/notification_service.dart';
import 'package:piwigo_ng/data/services/local/preferences_service.dart';
import 'package:piwigo_ng/data/services/local/receive_sharing.dart';
import 'package:piwigo_ng/data/services/local/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setUITheme();
  await SharedIntent.receiveSharedData();
  HttpOverrides.global = SSLHttpOverrides();
  appPreferences = await SharedPreferences.getInstance();
  runApp(const App());
  _clearUnusedStorage();
  initLocalNotifications();
  initializeWorkManager();
}

Future<void> _clearUnusedStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('STORAGE_VERSION') &&
      prefs.getString('STORAGE_VERSION') != '2.0.0') {
    prefs.clear();
    const FlutterSecureStorage().deleteAll();
    prefs.setString('STORAGE_VERSION', '2.0.0');
  }
}

Future<void> _setUITheme() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool isDark = sharedPreferences.getBool(ThemeNotifier.themeKey) ??
      (ThemeMode.system == ThemeMode.dark);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black.withValues(alpha: 0.001),
    statusBarColor: Colors.black.withValues(alpha: 0.001),
    statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
  ));
}
