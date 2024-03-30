import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piwigo_ng/app.dart';
import 'package:piwigo_ng/core/injector/injector.dart';
import 'package:piwigo_ng/network/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = SSLHttpOverrides();
  await init();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // appPreferences = await SharedPreferences.getInstance();
  runApp(const App());
  // initLocalNotifications();
  // initializeWorkManager();
}

// Future<void> _setUITheme() async {
//   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//   bool isDark = sharedPreferences.getBool(ThemeNotifier.themeKey) ?? (ThemeMode.system == ThemeMode.dark);
//   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//     systemNavigationBarColor: Colors.black.withOpacity(0.001),
//     statusBarColor: Colors.black.withOpacity(0.001),
//     statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
//   ));
// }
