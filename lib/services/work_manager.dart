import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:piwigo_ng/api/upload.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final Directory appDocDir = Directory('/storage/emulated/0/Pictures/Messenger');
    print(appDocDir.listSync());
    final List<File> files = appDocDir.listSync().whereType<File>().toList();
    List<XFile> uploadFiles = files.map<XFile>((file) => XFile(file.path)).toList();
    final result = await uploadPhotos(uploadFiles, 92);
    print(result);
    return Future.value(true);
  });
}

void initializeWorkManager() {
  Workmanager().initialize(
    callbackDispatcher, // The top level function, aka callbackDispatcher
    isInDebugMode: true, // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );

  Workmanager().cancelByTag("auto-upload");

  // Workmanager().registerOneOffTask(
  //   "task-identifier",
  //   "upload",
  //   tag: "auto-upload",
  //   // frequency: const Duration(minutes: 15),
  // );
}
