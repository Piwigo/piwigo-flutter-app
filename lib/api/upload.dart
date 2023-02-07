import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:piwigo_ng/api/api_client.dart';
import 'package:piwigo_ng/api/authentication.dart';
import 'package:piwigo_ng/app.dart';
import 'package:piwigo_ng/components/dialogs/confirm_dialog.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/services/upload_notifier.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:provider/provider.dart';

import '../services/chunked_uploader.dart';
import '../services/notification_service.dart';

Future<void> _showUploadNotification({bool success = true}) async {
  final android = AndroidNotificationDetails(
    'piwigo-ng-upload',
    'Piwigo NG Upload',
    channelDescription: 'piwigo-ng',
    priority: Priority.high,
    importance: Importance.high,
  );
  final platform = NotificationDetails(android: android);
  await localNotification.show(
    1,
    success ? 'Success' : 'Failure',
    success ? appStrings.imageUploadCompleted_message : appStrings.uploadError_message,
    platform,
  );
}

Future<List<Map<String, dynamic>>> uploadPhotos(
  List<XFile> photos,
  int albumId, {
  Map<String, dynamic> info = const {},
}) async {
  /// Check if Wifi is enabled and working
  if (Preferences.getWifiUpload) {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.wifi) {
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

  List<Map<String, dynamic>> result = [];
  List<int> uploadCompletedList = [];
  List<UploadItem> items = [];
  FlutterSecureStorage storage = const FlutterSecureStorage();
  String? url = await storage.read(key: 'SERVER_URL');
  if (url == null) return [];
  String? username = await storage.read(key: 'SERVER_USERNAME');
  String? password = await storage.read(key: 'SERVER_PASSWORD');
  UploadNotifier uploadNotifier = App.appKey.currentContext!.read<UploadNotifier>();

  /// Creates Upload Item list for the upload notifier
  for (var photo in photos) {
    File? compressedFile;
    if (Preferences.getRemoveMetadata) {
      compressedFile = await compressFile(photo);
    } else {
      compressedFile = File(photo.path);
    }
    items.add(UploadItem(
      file: compressedFile,
      albumId: albumId,
    ));
  }

  uploadNotifier.addItems(items);

  /// Upload loop
  for (var item in items) {
    try {
      /// Make Request
      Response? response = await uploadChunk(
        photo: item.file,
        category: albumId,
        url: url,
        username: username,
        password: password,
        info: info,
        onProgress: (progress) {
          debugPrint("$progress");
          item.progress.sink.add(progress);
        },
      );
      if (response != null) {
        var data = json.decode(response.data);
        if (data['stat'] != 'fail') {
          result.add({
            'id': data['result']['id'],
            'url': data['result']['element_url'],
          });

          /// Notify provider upload completed
          uploadNotifier.itemUploadCompleted(item);
          if (Preferences.getDeleteAfterUpload) {
            // todo: delete real file path, not the cached one.
          }
        } else {
          uploadNotifier.itemUploadCompleted(item, error: true);
        }
      } else {
        uploadNotifier.itemUploadCompleted(item, error: true);
      }
    } catch (e) {
      debugPrint("$e");
    }
  }
  if (Preferences.getUploadNotification) {
    if (result.isEmpty) {
      _showUploadNotification(success: false);
    }
    _showUploadNotification(success: true);
  }
  if (result.isEmpty) return [];
  uploadCompletedList = result.map<int>((e) => e['id']).toList();
  try {
    await uploadCompleted(uploadCompletedList, albumId);
    if (await methodExist('community.images.uploadCompleted')) {
      await communityUploadCompleted(uploadCompletedList, albumId);
    }
  } on DioError catch (e) {
    debugPrint(e.message);
  }

  return result;
}

Future<Response?> uploadChunk({
  required File photo,
  required int category,
  required String url,
  Map<String, dynamic> info = const {},
  Function(double)? onProgress,
  String? username,
  String? password,
}) async {
  Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.images.uploadAsync',
  };
  Map<String, dynamic> fields = {
    'username': username,
    'password': password,
    'filename': photo.path.split('/').last,
    'category': category,
  };

  if (info['name'] != '' && info['name'] != null) fields['name'] = info['name'];
  if (info['comment'] != '' && info['comment'] != null) fields['comment'] = info['comment'];
  if (info['tag_ids'].isNotEmpty) fields['tag_ids'] = info['tag_ids'];
  if (info['level'] != -1) fields['level'] = info['level'];

  ChunkedUploader chunkedUploader = ChunkedUploader(Dio(
    BaseOptions(
      baseUrl: url,
    ),
  ));

  return await chunkedUploader.upload(
    path: '/ws.php',
    filePath: photo.absolute.path,
    maxChunkSize: 100000,
    params: queries,
    method: 'POST',
    data: fields,
    contentType: Headers.formUrlEncodedContentType,
    onUploadProgress: (value) {
      if (onProgress != null) onProgress(value);
    },
  );
}

Future<File> compressFile(XFile file) async {
  try {
    final filePath = file.path;
    var dir = await getTemporaryDirectory();
    final String filename = filePath.split('/').last;
    final outPath = "${dir.absolute.path}/$filename";

    var result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: (Preferences.getUploadQuality * 100).round(),
      keepExif: false,
    );
    debugPrint("Upload Compress $result");
    if (result != null) return result;
  } catch (e) {
    debugPrint(e.toString());
  }
  return File(file.path);
}

Future<bool> uploadCompleted(List<int> imageId, int categoryId) async {
  Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.images.uploadCompleted',
  };
  FormData formData = FormData.fromMap({
    'image_id': imageId,
    'pwg_token': appPreferences.getString(Preferences.tokenKey),
    'category_id': categoryId,
  });

  try {
    Response response = await ApiClient.post(data: formData, queryParameters: queries);
    if (response.statusCode == 200) {
      return true;
    }
  } on DioError catch (e) {
    debugPrint("$e");
  }
  return false;
}

Future<bool> communityUploadCompleted(List<int> imageId, int categoryId) async {
  Map<String, String> queries = {
    'format': 'json',
    'method': 'community.images.uploadCompleted',
  };
  FormData formData = FormData.fromMap({
    'image_id': imageId,
    'pwg_token': appPreferences.getString(Preferences.tokenKey),
    'category_id': categoryId,
  });
  try {
    Response response = await ApiClient.post(data: formData, queryParameters: queries);
    if (response.statusCode == 200) {
      return true;
    }
  } on DioError catch (e) {
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
