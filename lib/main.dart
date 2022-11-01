import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:piwigo_ng/app.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/services/work_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeWorkManager();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black.withOpacity(0.1),
    statusBarColor: Colors.black.withOpacity(0.1),
  ));
  runApp(const App());
  _clearUnusedStorage();
  appPreferences = await SharedPreferences.getInstance();
}

void _clearUnusedStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('STORAGE_VERSION') && prefs.getString('STORAGE_VERSION') != "2.0.0") {
    prefs.clear();
    const FlutterSecureStorage().deleteAll();
    prefs.setString('STORAGE_VERSION', "2.0.0");
  }
}
