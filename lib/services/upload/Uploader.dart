import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/ImageAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/views/components/snackbars.dart';
import 'package:provider/provider.dart';

import '../UploadStatusProvider.dart';
import 'chunked_uploader.dart';

class Uploader {
  BuildContext mainContext;


  Uploader(this.mainContext);

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
      isSuccess ? appStrings(mainContext).imageUploadCompleted_message : appStrings(mainContext).uploadError_message,
      platform,
    );
  }

  Future<void> uploadPhotos(BuildContext context, List<XFile> photos, String category, Map<String, dynamic> info,) async {
    Map<String, dynamic> result = {
      'isSuccess': true,
      'filePath': null,
      'error': null,
    };
    List<int> uploadedImages = [];
    final uploadStatusProvider = Provider.of<UploadStatusNotifier>(context, listen: false);

    uploadStatusProvider.status = true;
    uploadStatusProvider.max = photos.length;
    uploadStatusProvider.current = 1;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appStrings(context).imageUploadTableCell_uploading),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      for(var element in photos) {
        uploadStatusProvider.status = true;

        XFile photo;
        if (API.prefs.getBool("remove_metadata")) {
          photo = await testCompressAndGetFile(element);
        } else {
          photo = element;
        }

        Response response = await uploadChunk(context, photo, category, info,
            (progress) {
              debugPrint("$progress");
              uploadStatusProvider.progress = progress;
            },
        );
        var data = json.decode(response.data);

        if(data["stat"] == "fail") {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(context, response.data));
        } else if(data["result"]["id"] != null) {
          uploadedImages.add(data["result"]["id"]);
        }
        uploadStatusProvider.current++;
      }
      uploadStatusProvider.reset();
    } catch (e) {
      debugPrint(e.message);
      uploadStatusProvider.reset();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(context, appStrings(context).uploadError_title));
    }

    try {
      await uploadCompleted(uploadedImages, int.parse(category));
      await communityUploadCompleted(uploadedImages, int.parse(category));

      // cleanTempDirectory();
    } on DioError catch (e) {
      debugPrint(e.message);
    }

    await _showUploadNotification(result);
  }

  Future<XFile> testCompressAndGetFile(XFile file) async {

    Directory cacheDir = await getTemporaryDirectory();

    var result = await FlutterImageCompress.compressAndGetFile(
      await FlutterAbsolutePath.getAbsolutePath(file.path),
      cacheDir.absolute.path + file.name,
    );

    return XFile(result.path, name: file.name);
  }

  void cleanTempDirectory() async {
    Directory cacheDir = await getTemporaryDirectory();
    cacheDir.deleteSync(recursive: true);
  }

  Future<Response> uploadChunk(BuildContext context, XFile photo,
    String category, Map<String, dynamic> info,
    Function(double) onProgress,
  ) async {
    Map<String, String> queries = {
      "format":"json",
      "method": "pwg.images.uploadAsync"
    };
    Map<String, dynamic> fields = {
      'username': await API.storage.read(key: "username"),
      'password': await API.storage.read(key: "password"),
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

    return await chunkedUploader.upload(
      context: context,
      path: "/ws.php",
      filePath: await FlutterAbsolutePath.getAbsolutePath(photo.path),
      maxChunkSize: API.prefs.getInt("upload_form_chunk_size")*1000,
      params: queries,
      method: 'POST',
      data: fields,
      contentType: Headers.formUrlEncodedContentType,
      onUploadProgress: (value) => onProgress(value),
    );
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