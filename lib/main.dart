import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:piwigo_ng/api/api_client.dart';
import 'package:piwigo_ng/app.dart';
import 'package:piwigo_ng/services/shared_preferences_service.dart';
import 'package:piwigo_ng/services/uploader.dart';
import 'package:piwigo_ng/services/work_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await _initializeCookies();
  // ApiClient().createDio();
  initializeWorkManager();
  runApp(const App());
  _clearUnusedStorage();
  appPreferences = await SharedPreferences.getInstance();
}

Future<void> _initializeCookies() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  ApiClient.cookieJar = PersistCookieJar(storage: FileStorage(appDocPath));
}

void _clearUnusedStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('STORAGE_VERSION') && prefs.getString('STORAGE_VERSION') != "2.0.0") {
    prefs.clear();
    const FlutterSecureStorage().deleteAll();
    prefs.setString('STORAGE_VERSION', "2.0.0");
  }
}

void _getPhotosDir() async {
  final Directory appDocDir = Directory('/storage/emulated/0/Pictures/Messenger');
  print(appDocDir.listSync());
  final List<File> files = appDocDir.listSync().whereType<File>().toList();
  List<XFile> uploadFiles = files.map<XFile>((file) => XFile(file.path)).toList();
  final result = await uploadPhotos(uploadFiles, "92");
  print(result);
}
