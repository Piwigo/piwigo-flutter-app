import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:piwigo_ng/app.dart';
import 'package:piwigo_ng/components/dialogs/confirm_dialog.dart';
import 'package:piwigo_ng/network/api_client.dart';
import 'package:piwigo_ng/network/api_interceptor.dart';
import 'package:piwigo_ng/network/authentication.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/services/upload_notifier.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/views/upload/upload_status_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/chunked_uploader.dart';
import '../services/notification_service.dart';

/// Handle Android API 33 permissions
Future<bool> askMediaPermission() async {
  bool storage = true;
  bool videos = true;
  bool photos = true;

  // Only check for storage < Android 13
  AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
  if (androidInfo.version.sdkInt >= 33) {
    videos = await Permission.videos.status.isGranted;
    photos = await Permission.photos.status.isGranted;

    if (!videos) {
      videos = await Permission.videos.request().isGranted;
    }
    if (!photos) {
      photos = await Permission.photos.request().isGranted;
    }
  } else {
    storage = await Permission.storage.status.isGranted;
    if (!storage) {
      storage = await Permission.storage.request().isGranted;
    }
  }

  if (storage && (videos || photos)) {
    return true;
  }
  return false;
}

/// Prepare and upload with [uploadChunk] a list of files.
Future<List<int>> uploadPhotos(
  List<XFile> photos,
  int albumId, {
  Map<String, dynamic> info = const {},
}) async {
  // Check if Wifi is enabled and working before processing
  if (Preferences.getWifiUpload) {
    var connectivity = await Connectivity().checkConnectivity();
    if (!connectivity.contains(ConnectivityResult.wifi)) {
      if (!(await showConfirmDialog(
        App.navigatorKey.currentContext!,
        title: appStrings.uploadNoWiFiNetwork,
        cancel: appStrings.alertCancelButton,
        confirm: appStrings.imageUploadDetailsButton_title,
      ))) {
        return [];
      }
    }
  }

  // Initialize variables
  List<int> result = [];
  List<UploadItem> items = [];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  FlutterSecureStorage storage = const FlutterSecureStorage();
  String? url = prefs.getString(Preferences.serverUrlKey);
  if (url == null) return [];
  String? username = await storage.read(key: Preferences.usernameKey);
  String? password = await storage.read(key: Preferences.passwordKey);
  UploadNotifier uploadNotifier = App.appKey.currentContext!.read<UploadNotifier>();
  int nbError = 0;

  // Creates Upload Item list for the upload notifier
  for (var photo in photos) {
    File? uploadFile = File(photo.path);

    items.add(UploadItem(
      file: uploadFile,
      albumId: albumId,
    ));
  }

  // Add items to the queue
  uploadNotifier.addItems(items);

  // Closes the Upload Configuration page and opens the Upload Status page
  App.navigatorKey.currentState?.popAndPushNamed(UploadStatusPage.routeName);

  // Iterate on each item
  for (UploadItem item in items) {
    try {
      // Upload image
      Response? response = await uploadChunk(
        photo: item.file,
        category: albumId,
        url: url,
        username: username,
        password: password,
        info: info,
        cancelToken: item.cancelToken,
        onProgress: (progress) {
          item.progress.sink.add(progress);
        },
      );

      // Handle result
      if (response == null || json.decode(response.data)['stat'] == 'fail') {
        if (!item.cancelToken.isCancelled) {
          uploadNotifier.itemUploadCompleted(item, error: true);
          nbError++;
        }
      } else {
        var data = json.decode(response.data);
        result.add(data['result']['id']);

        // Notify provider the upload has completed.
        uploadNotifier.itemUploadCompleted(item);
        if (Preferences.getDeleteAfterUpload) {
          // todo: delete real file path, not the cached one.
        }
      }
    } on DioException catch (e) {
      debugPrint("${e.message}");
      debugPrint("${e.stackTrace}");
      uploadNotifier.itemUploadCompleted(item, error: true);
      nbError++;
    } catch (e) {
      debugPrint("$e");
      if (e is Error) {
        debugPrint("${e.stackTrace}");
      }
      uploadNotifier.itemUploadCompleted(item, error: true);
      nbError++;
    }
  }

  // Send notifications
  showUploadNotification(nbError, result.length);

  // If no image was successfully uploaded, no call for "uploadCompleted"
  if (result.isEmpty) return [];

  // Empty Piwigo lounge
  try {
    await uploadCompleted(result, albumId);
    if (await methodExist('community.images.uploadCompleted')) {
      await communityUploadCompleted(result, albumId);
    }
  } on DioException catch (e) {
    debugPrint(e.message);
  }

  return result;
}

/// Upload images as chunks using [ChunkedUploader]
Future<Response?> uploadChunk({
  required File photo,
  required int category,
  required String url,
  Map<String, dynamic> info = const {},
  Function(double)? onProgress,
  String? username,
  String? password,
  CancelToken? cancelToken,
}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Request query parameters
  Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.images.uploadAsync',
  };

  // Initialize fields
  Map<String, dynamic> fields = {
    'username': username,
    'password': password,
    'filename': photo.path.split('/').last,
    'category': category,
  };

  // Filter fields
  if (info['name'] != '' && info['name'] != null) fields['name'] = info['name'];
  if (info['comment'] != '' && info['comment'] != null) fields['comment'] = info['comment'];
  if (info['tag_ids']?.isNotEmpty ?? false) fields['tag_ids'] = info['tag_ids'].join(',');
  if (info['level'] != -1 && info['level'] != null) fields['level'] = info['level'];

  // Create dio client
  Dio dio = Dio(
    BaseOptions(
      baseUrl: url,
    ),
  )..interceptors.add(ApiInterceptor());

  // Initialize chunk uploader service
  ChunkedUploader chunkedUploader = ChunkedUploader(dio);

  // Upload image as chunks
  return await chunkedUploader.upload(
    path: '/ws.php',
    filePath: photo.absolute.path,
    maxChunkSize: (prefs.getInt(Preferences.uploadChunkSizeKey) ?? 100) * 1000,
    params: queries,
    method: 'POST',
    data: fields,
    cancelToken: cancelToken,
    contentType: Headers.formUrlEncodedContentType,
    onUploadProgress: (value) {
      if (onProgress != null) onProgress(value);
    },
  );
}

Future<bool> uploadCompleted(List<int> imageId, int categoryId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.images.uploadCompleted',
  };
  FormData formData = FormData.fromMap({
    'image_id': imageId,
    'pwg_token': prefs.getString(Preferences.tokenKey),
    'category_id': categoryId,
  });

  try {
    Response response = await ApiClient.post(data: formData, queryParameters: queries);
    if (response.statusCode == 200) {
      return true;
    }
  } on DioException catch (e) {
    debugPrint("$e");
  }
  return false;
}

Future<bool> communityUploadCompleted(List<int> imageId, int categoryId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Map<String, String> queries = {
    'format': 'json',
    'method': 'community.images.uploadCompleted',
  };
  FormData formData = FormData.fromMap({
    'image_id': imageId,
    'pwg_token': prefs.getString(Preferences.tokenKey),
    'category_id': categoryId,
  });
  try {
    Response response = await ApiClient.post(data: formData, queryParameters: queries);
    if (response.statusCode == 200) {
      return true;
    }
  } on DioException catch (e) {
    debugPrint("$e");
  }
  return false;
}

class FlutterAbsolutePath {
  static const MethodChannel _channel = MethodChannel('flutter_absolute_path');

  /// Gets absolute path of the file from android URI or iOS PHAsset identifier
  /// The return of this method can be used directly with flutter [File] class
  static Future<String> getAbsolutePath(String uri) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'uri': uri,
    };
    final String path = await _channel.invokeMethod('getAbsolutePath', params);
    return path;
  }
}
