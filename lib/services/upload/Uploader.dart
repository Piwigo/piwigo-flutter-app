import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/views/components/snackbars.dart';

import 'chunked_uploader.dart';

class Uploader {
  BuildContext context;
  SnackBar snackBar;

  Uploader(this.context) {
    snackBar = SnackBar(
      content: Text(appStrings(context).imageUploadTableCell_uploading),
      duration: Duration(seconds: 2),
    );
  }

  Future<void> _showUploadNotification(Map<String, dynamic> downloadStatus) async {
    final android = AndroidNotificationDetails(
        'channel id',
        'channel name',
        channelDescription: 'channel description',
        priority: Priority.high,
        importance: Importance.max
    );
    final platform = NotificationDetails(android: android);
    final isSuccess = downloadStatus['isSuccess'];

    await API.localNotification.show(
      1,
      isSuccess ? 'Success' : 'Failure',
      isSuccess ? appStrings(context).imageUploadCompleted_message : appStrings(context).uploadError_message,
      platform,
    );
  }

  Future<void> uploadPhotos(List<XFile> photos, String category, Map<String, dynamic> info) async {
    Map<String, dynamic> result = {
      'isSuccess': true,
      'filePath': null,
      'error': null,
    };

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    for(var element in photos) {
      Response response = await uploadChunk(element, category, info);

      if(json.decode(response.data)["stat"] == "fail") {
        print("Request failed: ${response.statusCode}");

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(context, response.data));
      }
    }

    print('new status');

    await _showUploadNotification(result);
  }

  void upload(XFile photo, String category) async {
    Map<String, String> queries = {"format":"json", "method": "pwg.images.upload"};

    List<int> imageData = await photo.readAsBytes();

    Dio dio = new Dio(
      BaseOptions(
        baseUrl: API.prefs.getString("base_url"),
      ),
    );

    FormData formData =  FormData.fromMap({
      "category": category,
      "pwg_token": API.prefs.getString("pwg_token"),
      "file": MultipartFile.fromBytes(
        imageData,
        filename: photo.path.split('/').last,
      ),
      "name": photo.path.split('/').last,
    });

    Response response = await dio.post("ws.php",
      data: formData,
      queryParameters: queries,
    );

    if (response.statusCode == 200) {
      print('Upload ${response.data}');
      if(json.decode(response.data)["stat"] == "ok") {}
    } else {
      print("Request failed: ${response.statusCode}");
    }
  }
  Future<Response> uploadChunk(XFile photo, String category, Map<String, dynamic> info) async {
    Map<String, String> queries = {
      "format":"json",
      "method": "pwg.images.uploadAsync"
    };
    Map<String, dynamic> fields = {
      'username': API.prefs.getString("username"),
      'password': API.prefs.getString("password"),
      'filename': photo.path.split('/').last,
      'category': category,
    };
    if(info['name'] != '' && info['name'] != null) fields['name'] = info['name'];
    if(info['comment'] != '' && info['comment'] != null) fields['comment'] = info['comment'];
    if(info['tag_ids'].isNotEmpty) fields['tag_ids'] = info['tag_ids'];
    if(info['level'] != -1) fields['level'] = info['level'];

    ChunkedUploader chunkedUploader = ChunkedUploader(new Dio(
      BaseOptions(
        baseUrl: API.prefs.getString("base_url"),
      ),
    ));
    print(await FlutterAbsolutePath.getAbsolutePath(photo.path));
    try {
      Future<Response> response = chunkedUploader.upload(
        context: context,
        path: "/ws.php",
        filePath: await FlutterAbsolutePath.getAbsolutePath(photo.path),
        maxChunkSize: API.prefs.getInt("upload_form_chunk_size")*1000,
        params: queries,
        method: 'POST',
        data: fields,
        contentType: Headers.formUrlEncodedContentType,
        onUploadProgress: (value) {
          // print('${photo.name} $progress');
        },
      );
      return response;
    } on DioError catch (e) {
      print('Dio upload chunk error $e');
      return Future.value(null);
    }
  }
}


class FlutterAbsolutePath {
  static const MethodChannel _channel =
  const MethodChannel('flutter_absolute_path');

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