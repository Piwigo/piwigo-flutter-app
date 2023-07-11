import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:heic_to_jpg/heic_to_jpg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/models/status_model.dart';
import 'package:piwigo_ng/network/api_client.dart';
import 'package:piwigo_ng/network/api_error.dart';
import 'package:piwigo_ng/network/api_interceptor.dart';
import 'package:piwigo_ng/network/upload.dart';
import 'package:piwigo_ng/services/chunked_uploader.dart';
import 'package:piwigo_ng/services/notification_service.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class AutoUploadManager {
  final String taskKey = 'com.piwigo.piwigo_ng.auto_upload';
  final String tag = '<auto_upload>';
  late Workmanager _manager;

  static final CookieJar cookieJar = CookieJar();
  static final Dio dio = Dio(BaseOptions())
    ..interceptors.add(CookieManager(cookieJar))
    ..interceptors.add(ApiInterceptor())
    ..httpClientAdapter = ApiClient.sslHttpClientAdapter;

  AutoUploadManager() {
    _manager = Workmanager();
  }

  Future<void> endAutoUpload() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(AutoUploadPreferences.enabledKey, false);
    await _manager.cancelByUniqueName(taskKey);
  }

  Future<bool> startAutoUpload() async {
    // Requires storage permission
    if (!await askMediaPermission()) return false;
    // End previous task if it was running
    await endAutoUpload();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Request notifications if they are enabled
    if (prefs.getBool(AutoUploadPreferences.notificationKey) ?? false) {
      await askNotificationPermissions();
    }
    // Save a copy of the current account credentials
    await AutoUploadPreferences.saveCredentials();
    // Get task frequency
    int hours = prefs.getInt(AutoUploadPreferences.frequencyKey) ??
        Settings.defaultAutoUploadFrequency;
    // Enable auto upload
    prefs.setBool(AutoUploadPreferences.enabledKey, true);
    // Register task
    await _manager.registerPeriodicTask(
      taskKey,
      taskKey,
      frequency: Duration(hours: hours),
    );
    return true;
  }

  Future<bool> autoUpload() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check upload on WiFi only setting
    if (prefs.getBool(Preferences.wifiUploadKey) ?? false) {
      debugPrint('Check wifi only');
      var connectivity = await Connectivity().checkConnectivity();
      if (connectivity != ConnectivityResult.wifi) {
        debugPrint('No wifi');
        return false;
      }
      debugPrint('Has wifi');
    }

    final Directory? appDocDir = await getUploadDirectory();
    if (appDocDir == null) return false;

    // Get source folder content
    List<FileSystemEntity> dirFiles = appDocDir.listSync(recursive: true);

    // Remove folders and links
    List<File> files = dirFiles
        .where((file) => file is File)
        .map<File>((e) => e as File)
        .toList();

    // Convert .heic files to .jpg
    for (File file in files) {
      if (file.path.endsWith('.heic')) {
        debugPrint("${file.path} is Heic !");
        String? jpgPath = await HeicToJpg.convert(
          file.path,
        );
        debugPrint("From ${file.path}...\nto $jpgPath");
        if (jpgPath != null) {
          files.remove(file);
          files.add(File(jpgPath));
        }
      }
    }
    debugPrint("List files: ${files.toString()}");
    await autoUploadPhotos(files);
    return true;
  }

  Future<Directory?> getUploadDirectory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? path = prefs.getString(AutoUploadPreferences.sourceKey);
    if (path == null) return null;
    return Directory(path);
  }

  Future<void> autoUploadPhotos(List<File> photos) async {
    if (photos.isEmpty) return;
    List<int> result = [];
    int nbError = 0;

    // Get preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FlutterSecureStorage storage = const FlutterSecureStorage();

    // Get server url
    String? url = prefs.getString(Preferences.serverUrlKey);
    if (url == null) return;

    // Initialize auto upload Dio
    dio.options.baseUrl = url;
    cookieJar.delete(Uri.parse(url));

    // Get server credentials
    String? username =
        await storage.read(key: AutoUploadPreferences.usernameKey);
    String? password =
        await storage.read(key: AutoUploadPreferences.passwordKey);

    // Get destination album
    String? albumJson = prefs.getString(AutoUploadPreferences.destinationKey);
    if (albumJson == null) return null;
    AlbumModel destination = AlbumModel.fromJson(json.decode(albumJson));

    // Perform login
    ApiResult<bool> success = await _login(dio);
    if (!(success.data ?? false)) {
      debugPrint('login error');
      return;
    }

    // Check if images are already in the server
    List<File> newPhotos = await _checkImagesNotExist(photos);
    if (newPhotos.isEmpty) {
      debugPrint('All photos already exist');
      return;
    }

    // Perform upload
    for (File file in newPhotos) {
      debugPrint("Try upload ${file.path}");

      File? uploadFile;

      // Compress file
      uploadFile = await compressFile(XFile(file.path));
      if (uploadFile == null) {
        uploadFile = file;
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

        print(response?.statusCode);

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
        debugPrint("Dio Error ${e.type}");
        nbError++;
      } on Error catch (e) {
        debugPrint("Error $e");
        debugPrint("${e.stackTrace}");
        nbError++;
      } catch (e) {
        debugPrint("Unknown $e");
        nbError++;
      }
    }

    // If no changes, end task iteration
    if (result.isEmpty) return;

    await showAutoUploadNotification(nbError, result.length);

    await _emptyLunge(result, destination.id);
  }

  Future<ApiResult<bool>> _login(Dio dio) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    String? url = await secureStorage.read(key: AutoUploadPreferences.urlKey);
    if (url == null || url.isEmpty) {
      return ApiResult<bool>(
        data: false,
        error: ApiErrors.wrongServerUrl,
      );
    }

    String? username =
        await secureStorage.read(key: AutoUploadPreferences.usernameKey);
    String? password =
        await secureStorage.read(key: AutoUploadPreferences.passwordKey);

    if ((username == null || username.isEmpty) &&
        (password == null || password.isEmpty)) {
      return ApiResult<bool>(
        data: false,
        error: ApiErrors.wrongServerUrl,
      );
    }

    Map<String, String> queries = {
      'format': 'json',
      'method': 'pwg.session.login',
    };
    Map<String, dynamic> fields = {
      'username': username,
      'password': password,
    };

    try {
      Response response = await dio.post(
        'ws.php',
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
        ApiResult<StatusModel> status = await _sessionStatus();
        if (status.hasData) {
          secureStorage.write(
            key: AutoUploadPreferences.tokenKey,
            value: status.data!.pwgToken,
          );
          prefs.setString(
            Preferences.tokenKey,
            status.data!.pwgToken,
          );
        }
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

  Future<ApiResult<StatusModel>> _sessionStatus() async {
    Map<String, String> queries = {
      'format': 'json',
      'method': 'pwg.session.getStatus'
    };

    try {
      Response response = await dio.get('ws.php', queryParameters: queries);
      var data = json.decode(response.data);
      if (data['stat'] == 'ok') {
        var result = await _getMethods();
        if (result.data?.contains('community.session.getStatus') ?? false) {
          String? community = await _communityStatus();
          data['result']['real_user_status'] = community;
        }
        return ApiResult<StatusModel>(
          data: StatusModel.fromJson(data['result']),
        );
      }
    } on DioError catch (e) {
      debugPrint(e.message);
    } catch (e) {
      debugPrint('Error $e');
    }
    return ApiResult(
      error: ApiErrors.getStatusError,
    );
  }

  Future<String?> _communityStatus() async {
    Map<String, String> queries = {
      'format': 'json',
      'method': 'community.session.getStatus'
    };

    try {
      Response response = await dio.get('ws.php', queryParameters: queries);
      var data = json.decode(response.data);
      if (data['stat'] == 'ok') {
        return data['result']['real_user_status'];
      }
    } on DioError catch (e) {
      debugPrint(e.message);
    } catch (e) {
      debugPrint('Error $e');
    }
    return null;
  }

  Future<List<File>> _checkImagesNotExist(
    List<File> files, {
    bool returnExistFiles = false,
  }) async {
    Map<String, File> md5sumList = {};

    for (File file in files) {
      String md5sum = await ChunkedUploader.generateMd5(file.openRead());
      md5sumList[md5sum] = file;
    }

    final Map<String, String> queries = {
      'format': 'json',
      'method': 'pwg.images.exist',
      'md5sum_list': md5sumList.keys.join(','),
    };

    try {
      Response response = await dio.get(
        'ws.php',
        queryParameters: queries,
      );

      Map<String, dynamic> data = json.decode(response.data);
      if (data['stat'] == 'fail') return [];
      print(data['result']);
      Map<String, dynamic> existResult = data['result'];
      if (returnExistFiles) {
        existResult.removeWhere((key, value) => value == null);
      } else {
        existResult.removeWhere((key, value) => value != null);
      }
      return existResult.keys.map((md5sum) => md5sumList[md5sum]!).toList();
    } on DioError catch (e) {
      debugPrint('Edit images: ${e.message}');
    } on Error catch (e) {
      debugPrint('Edit images: ${e.stackTrace}');
    }
    return [];
  }

  Future<void> _emptyLunge(List<int> idList, int destinationId) async {
    try {
      await autoUploadCompleted(idList, destinationId);
      var result = await _getMethods();
      if (result.data?.contains('community.images.uploadCompleted') ?? false) {
        await communityAutoUploadCompleted(idList, destinationId);
      }
    } on DioError catch (e) {
      debugPrint(e.message);
    }
  }

  Future<ApiResult<List<String>>> _getMethods() async {
    Map<String, String> queries = {
      'format': 'json',
      'method': 'reflection.getMethodList'
    };

    try {
      Response response = await dio.get(
        'ws.php',
        queryParameters: queries,
      );
      Map<String, dynamic> data = json.decode(response.data);
      final List<String> methods =
          data['result']['methods'].map<String>((e) => e.toString()).toList();
      return ApiResult<List<String>>(data: methods);
    } on DioError catch (e) {
      debugPrint(e.message);
    } catch (e) {
      debugPrint('Error $e');
    }
    return ApiResult<List<String>>(error: ApiErrors.getMethodsError);
  }

  Future<bool> autoUploadCompleted(
    List<int> imageId,
    int categoryId,
  ) async {
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    Map<String, String> queries = {
      'format': 'json',
      'method': 'pwg.images.uploadCompleted',
    };
    FormData formData = FormData.fromMap({
      'image_id': imageId,
      'pwg_token':
          await secureStorage.read(key: AutoUploadPreferences.tokenKey),
      'category_id': categoryId,
    });

    try {
      Response response = await dio.post(
        'ws.php',
        data: formData,
        queryParameters: queries,
      );
      if (response.statusCode == 200) {
        return true;
      }
    } on DioError catch (e) {
      debugPrint("$e");
    }
    return false;
  }

  Future<bool> communityAutoUploadCompleted(
    List<int> imageId,
    int categoryId,
  ) async {
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    Map<String, String> queries = {
      'format': 'json',
      'method': 'community.images.uploadCompleted',
    };
    FormData formData = FormData.fromMap({
      'image_id': imageId,
      'pwg_token':
          await secureStorage.read(key: AutoUploadPreferences.tokenKey),
      'category_id': categoryId,
    });
    try {
      Response response = await dio.post(
        'ws.php',
        data: formData,
        queryParameters: queries,
      );
      if (response.statusCode == 200) {
        return true;
      }
    } on DioError catch (e) {
      debugPrint("$e");
    }
    return false;
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
    isInDebugMode: kDebugMode,
  );
}
