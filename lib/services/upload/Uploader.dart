import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:images_picker/images_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/SessionAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/views/components/SnackBars.dart';

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
        'channel description',
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

  Future<void> uploadPhotos(List<Media> photos, String category, Map<String, dynamic> info) async {
    Map<String, dynamic> result = {
      'isSuccess': true,
      'filePath': null,
      'error': null,
    };

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    for(var element in photos) {

      Response response = await uploadChunk(element, category, info);

      API.dio.clear();
      if(json.decode(response.data)["stat"] == "fail") {
        print("Request failed: ${response.statusCode}");

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(context, response.data));
      }
    }

    print('new status');
    createDio();

    await _showUploadNotification(result);
  }

  void createDio() async {
    API.dio = Dio();
    API.cookieJar = CookieJar();
    API.dio.interceptors.add(CookieManager(API.cookieJar));
    if(API.prefs.getBool("is_logged") != null && API.prefs.getBool("is_logged")) {
      API.dio.options.baseUrl = API.prefs.getString("base_url");
      if(API.prefs.getBool("is_guest") != null && !API.prefs.getBool("is_guest")) {
        await loginUser(API.prefs.getString("base_url"), API.prefs.getString("username"), API.prefs.getString("password"));
      } else {
        await loginGuest(API.prefs.getString("base_url"));
      }
    }
  }

  void upload(Media photo, String category) async {
    Map<String, String> queries = {"format":"json", "method": "pwg.images.upload"};

    var asset = Asset(photo.path, photo.path.split('/').last, photo.size.ceil(), photo.size.ceil());

    ByteData byteData = await asset.getByteData();
    List<int> imageData = byteData.buffer.asUint8List();

    FormData formData =  FormData.fromMap({
      "category": category,
      "pwg_token": API.prefs.getString("pwg_token"),
      "file": MultipartFile.fromBytes(
        imageData,
        filename: photo.path.split('/').last,
      ),
      "name": photo.path.split('/').last,
    });

    Response response = await API.dio.post("ws.php",
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
  Future<Response> uploadChunk(Media photo, String category, Map<String, dynamic> info) async {
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

    ChunkedUploader chunkedUploader = ChunkedUploader(API.dio);
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
          });
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