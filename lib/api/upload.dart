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

Future<void> _showUploadNotification([int nbError = 0, int nbImage = 0]) async {
  if (!Preferences.getUploadNotification) return;
  final android = AndroidNotificationDetails(
    'piwigo-ng-upload',
    'Piwigo NG Upload',
    channelDescription: 'piwigo-ng',
    priority: Priority.high,
    importance: Importance.high,
  );
  final platform = NotificationDetails(android: android);
  late String title;
  String? message;
  if (nbError == 0 && nbImage == 0) {
    // Upload cancelled
    title = appStrings.uploadCancelled_title;
  } else if (nbError == 0 && nbImage > 0) {
    // Upload completed
    title = appStrings.imageUploadCompleted_title;
    message = nbImage == 1 ? appStrings.imageUploadCompleted_message : appStrings.imageUploadCompleted_message1;
  } else if (nbError > 0 && nbImage != nbError) {
    // Upload partially completed
    title = appStrings.coreDataStore_WarningTitle;
    message = appStrings.imageUploadCompleted_warning;
  } else {
    // Upload failed
    title = appStrings.uploadError_title;
    message = appStrings.uploadError_message;
  }
  await localNotification.show(1, title, message, platform);
}

Future<List<int>> uploadPhotos(
  List<XFile> photos,
  int albumId, {
  Map<String, dynamic> info = const {},
}) async {
  // Check if Wifi is enabled and working
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

  List<int> result = [];
  List<UploadItem> items = [];
  FlutterSecureStorage storage = const FlutterSecureStorage();
  String? url = await storage.read(key: 'SERVER_URL');
  if (url == null) return [];
  String? username = await storage.read(key: 'SERVER_USERNAME');
  String? password = await storage.read(key: 'SERVER_PASSWORD');
  UploadNotifier uploadNotifier = App.appKey.currentContext!.read<UploadNotifier>();
  int nbError = 0;

  // Creates Upload Item list for the upload notifier
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

  await Future.wait(List<Future<void>>.generate(items.length, (index) async {
    UploadItem item = items[index];
    try {
      // Make Request
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

        // Notify provider upload completed
        uploadNotifier.itemUploadCompleted(item);
        if (Preferences.getDeleteAfterUpload) {
          // todo: delete real file path, not the cached one.
        }
      }
    } on DioError catch (e) {
      debugPrint("${e.type}");
    } catch (e) {
      debugPrint("$e");
      nbError++;
    }
  }));

  _showUploadNotification(nbError, result.length);
  if (result.isEmpty) return [];
  try {
    await uploadCompleted(result, albumId);
    if (await methodExist('community.images.uploadCompleted')) {
      await communityUploadCompleted(result, albumId);
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
  CancelToken? cancelToken,
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
  if (info['tag_ids'].isNotEmpty) fields['tag_ids'] = info['tag_ids'].join(',');
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
    cancelToken: cancelToken,
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
