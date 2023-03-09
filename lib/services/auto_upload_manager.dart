import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class AutoUploadManager {
  final String taskKey = 'com.piwigo.piwigo_ng.auto_upload';
  final String tag = '<auto_upload>';
  late Workmanager _manager;

  AutoUploadManager() {
    _manager = Workmanager();
  }

  Future<void> endAutoUpload() async {
    appPreferences.setBool(
      Preferences.autoUploadKey,
      false,
    );
    await _manager.cancelByUniqueName(taskKey);
  }

  Future<void> startAutoUpload() async {
    appPreferences.setBool(
      Preferences.autoUploadKey,
      true,
    );
    await _manager.registerPeriodicTask(
      taskKey,
      taskKey,
      frequency: const Duration(minutes: 15),
    );
  }

  Future<Directory?> getUploadDirectory() async {
    return await getTemporaryDirectory();
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint("Background $task");
    debugPrint(prefs.getString('UPLOAD_AUTHOR_NAME') ?? '');
    final Directory? appDocDir = await AutoUploadManager().getUploadDirectory();
    if (appDocDir == null) return false;
    debugPrint(appDocDir.listSync().toString());
    // final List<File> files = appDocDir.listSync().whereType<File>().toList();
    // List<XFile> uploadFiles = files.map<XFile>((file) => XFile(file.path)).toList();
    // final result = await uploadPhotos(uploadFiles, 92);
    // debugPrint(result.toString());
    return Future.value(true);
  });
}

void initializeWorkManager() {
  Workmanager().initialize(
    callbackDispatcher, // The top level function, aka callbackDispatcher
    isInDebugMode: true, // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );
}
