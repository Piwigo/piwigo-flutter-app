import 'dart:convert';
import 'dart:io';

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
import 'package:piwigo_ng/services/shared_preferences_service.dart';
import 'package:piwigo_ng/utils/localizations.dart';

import 'chunked_uploader.dart';
import 'notification_service.dart';

Future<void> _showUploadNotification({bool success = true}) async {
  if (!(appPreferences.getBool('upload_notification') ?? true)) return;
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
    success
        ? appStrings(App.appKey.currentContext!).imageUploadCompleted_message
        : appStrings(App.appKey.currentContext!).uploadError_message,
    platform,
  );
}

Future<List<Map<String, dynamic>>> uploadPhotos(
  List<XFile> photos,
  String category, {
  Map<String, dynamic>? info,
}) async {
  List<Map<String, dynamic>> result = [];
  List<int> uploadCompletedList = [];
  FlutterSecureStorage storage = const FlutterSecureStorage();
  String? url = await storage.read(key: 'SERVER_URL');
  if (url == null) return [];
  String? username = await storage.read(key: 'SERVER_USERNAME');
  String? password = await storage.read(key: 'SERVER_PASSWORD');
  try {
    for (var photo in photos) {
      var compressedFile = await compressFile(photo);
      if (compressedFile != null) {
        Response? response = await uploadChunk(
          photo: compressedFile,
          category: category,
          url: url,
          username: username,
          password: password,
          info: info,
          onProgress: (progress) {
            debugPrint("$progress");
          },
        );
        if (response != null) {
          var data = json.decode(response.data);
          if (data["stat"] != "fail") {
            result.add({
              "name": photo.name,
              "filename": photo.path.split("/").last,
              "url": data["result"]["element_url"],
            });
            uploadCompletedList.add(data["result"]["id"]);
          }
        }
      }
    }
    _showUploadNotification(success: true);
  } on DioError catch (e) {
    _showUploadNotification(success: false);
    debugPrint(e.message);
  }

  try {
    await uploadCompleted(uploadCompletedList, int.parse(category));
    if (await methodExist('community.images.uploadCompleted')) {
      await communityUploadCompleted(uploadCompletedList, int.parse(category));
    }
  } on DioError catch (e) {
    debugPrint(e.message);
  }

  return result;
}

Future<Response?> uploadChunk({
  required File photo,
  required String category,
  required String url,
  Map<String, dynamic>? info,
  Function(double)? onProgress,
  String? username,
  String? password,
}) async {
  Map<String, String> queries = {"format": "json", "method": "pwg.images.uploadAsync"};
  Map<String, dynamic> fields = {
    'username': username,
    'password': password,
    'filename': photo.path.split('/').last,
    'category': category,
  };

  ChunkedUploader chunkedUploader = ChunkedUploader(Dio(
    BaseOptions(
      baseUrl: url,
    ),
  ));

  return await chunkedUploader.upload(
    path: "/ws.php",
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

Future<File?> compressFile(XFile file) async {
  final filePath = file.path;
  var dir = await getTemporaryDirectory();
  String filename = filePath.split('/').last;
  final outPath = "${dir.path}/compressed_$filename";

  var result = await FlutterImageCompress.compressAndGetFile(
    filePath,
    outPath,
    quality: 10,
  );
  return result;
}

Future<Map<String, dynamic>> uploadCompleted(List<int> imageId, int categoryId) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.images.uploadCompleted",
  };
  FormData formData = FormData.fromMap({
    "image_id": imageId,
    "pwg_token": appPreferences.getString("pwg_token"),
    "category_id": categoryId,
  });
  try {
    Response response = await ApiClient.post(data: formData, queryParameters: queries);
    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      return {'stat': 'fail', 'result': response.statusMessage};
    }
  } catch (e) {
    var error = e as DioError;
    return {'stat': 'fail', 'result': error.message};
  }
}

Future<Map<String, dynamic>> communityUploadCompleted(List<int> imageId, int categoryId) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "community.images.uploadCompleted",
  };
  FormData formData = FormData.fromMap({
    "image_id": imageId,
    "pwg_token": appPreferences.getString("pwg_token"),
    "category_id": categoryId,
  });
  try {
    Response response = await ApiClient.post(data: formData, queryParameters: queries);
    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      return {'stat': 'fail', 'result': response.statusMessage};
    }
  } catch (e) {
    var error = e as DioError;
    return {'stat': 'fail', 'result': error.message};
  }
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
