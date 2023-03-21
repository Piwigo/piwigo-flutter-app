import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piwigo_ng/api/api_client.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/api/authentication.dart';
import 'package:piwigo_ng/api/upload.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/services/notification_service.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/settings.dart';
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(AutoUploadPrefs.autoUploadKey, false);
    await _manager.cancelByUniqueName(taskKey);
  }

  Future<void> startAutoUpload() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int hours = prefs.getInt(AutoUploadPrefs.autoUploadFrequencyKey) ?? Settings.defaultAutoUploadFrequency;
    prefs.setBool(AutoUploadPrefs.autoUploadKey, true);
    await _manager.registerPeriodicTask(
      taskKey,
      taskKey,
      frequency: Duration(hours: hours),
    );
  }

  Future<bool> autoUpload() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(Preferences.wifiUploadKey) ?? false) {
      print('Check wifi only');
      var connectivity = await Connectivity().checkConnectivity();
      if (connectivity != ConnectivityResult.wifi) {
        print('No wifi');
        return Future.value(false);
      }
      print('Has wifi');
    }
    final Directory? appDocDir = await getUploadDirectory();
    if (appDocDir == null) return false;
    List<FileSystemEntity> dirFiles = appDocDir.listSync();
    List<File> files = dirFiles.where((file) => file is File).map<File>((e) => e as File).toList();
    debugPrint("List files: ${files.toString()}");
    await autoUploadPhotos(files);
    return true;
  }

  Future<Directory?> getUploadDirectory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? path = prefs.getString(AutoUploadPrefs.autoUploadSourceKey);
    if (path == null) return null;
    return Directory(path);
  }

  Future<void> autoUploadPhotos(List<File> photos) async {
    if (photos.isEmpty) return;
    List<int> result = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FlutterSecureStorage storage = const FlutterSecureStorage();
    String? url = await storage.read(key: 'SERVER_URL');
    if (url == null) return;
    String? username = await storage.read(key: 'SERVER_USERNAME');
    String? password = await storage.read(key: 'SERVER_PASSWORD');
    int nbError = 0;
    String? albumJson = prefs.getString(AutoUploadPrefs.autoUploadDestinationKey);
    if (albumJson == null) return null;
    AlbumModel destination = AlbumModel.fromJson(json.decode(albumJson));

    print('Try login');
    // todo: login
    // login
    ApiResult<bool> success = await loginUser(
      url,
      username: username ?? '',
      password: password ?? '',
    );

    if (!(success.data ?? false)) {
      print('login error');
      return;
    }
    print('Login success');

    // upload
    for (File file in photos) {
      print("Try upload ${file.path}");
      if (prefs.getBool(Preferences.removeMetadataKey) ?? Settings.defaultRemoveMetadata) {
        file = await compressFile(XFile(file.path));
      }
      try {
        // Make Request
        Response? response = await uploadChunk(
          photo: file,
          category: destination.id,
          url: url,
          username: username,
          password: password,
        );

        // Handle result
        if (response == null || json.decode(response.data)['stat'] == 'fail') {
          nbError++;
        } else {
          print("Upload success ${response.data}");
          var data = json.decode(response.data);
          result.add(data['result']['id']);
          if (prefs.getBool(Preferences.deleteAfterUploadKey) ?? false) {
            // todo: delete file
          }
        }
      } on DioError catch (e) {
        debugPrint("${e.type}");
        nbError++;
      } on Error catch (e) {
        debugPrint("$e");
        debugPrint("${e.stackTrace}");
        nbError++;
      } catch (e) {
        debugPrint("$e");
        nbError++;
      }
    }

    // notifications
    showAutoUploadNotification(nbError, result.length);
    if (result.isEmpty) return;
    print('Empty lunge');
    // empty lunge
    try {
      bool uploadCompletedSuccess = await uploadCompleted(result, destination.id);
      print(uploadCompletedSuccess);
      if (await methodExist('community.images.uploadCompleted')) {
        await communityUploadCompleted(result, destination.id);
      }
    } on DioError catch (e) {
      debugPrint(e.message);
    }
  }

  Future<ApiResult<bool>> loginAutoUpload(
    String url, {
    String username = '',
    String password = '',
  }) async {
    if (url.isEmpty) {
      return ApiResult<bool>(
        data: false,
        error: ApiErrors.wrongServerUrl,
      );
    }

    ApiClient.cookieJar.deleteAll();
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    await secureStorage.write(key: 'SERVER_URL', value: url);

    if (username.isEmpty && password.isEmpty) {
      return ApiResult<bool>(
        data: false,
        error: ApiErrors.wrongServerUrl,
      );
    }

    Map<String, String> queries = {
      'format': 'json',
      'method': 'pwg.session.login',
    };
    Map<String, String> fields = {
      'username': username,
      'password': password,
    };

    try {
      Response response = await ApiClient.post(
        data: FormData.fromMap(fields),
        options: Options(contentType: Headers.formUrlEncodedContentType),
        queryParameters: queries,
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.data);
        if (data['stat'] == 'fail') {
          return ApiResult<bool>(
            data: false,
            error: ApiErrors.wrongLoginId,
          );
        }
        await sessionStatus();
        return ApiResult<bool>(
          data: true,
        );
      }
      return ApiResult<bool>(
        data: false,
        error: ApiErrors.wrongLoginId,
      );
    } on DioError catch (e) {
      debugPrint(e.message);
    } catch (e) {
      debugPrint('Error $e');
    }
    return ApiResult<bool>(
      data: false,
      error: ApiErrors.wrongServerUrl,
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("Background $task");
    return await AutoUploadManager().autoUpload();
  });
}

void initializeWorkManager() {
  Workmanager().initialize(
    callbackDispatcher, // The top level function, aka callbackDispatcher
    isInDebugMode: true, // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );
}
