import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

Future<ApiResult<bool>> loginUser(
  String url,
  String username,
  String password,
) async {
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  await secureStorage.write(key: 'SERVER_URL', value: url);

  if (username.isEmpty && password.isEmpty) {
    ApiResult<StatusModel> status = await sessionStatus();
    if (status.hasData) {
      savePreferences(status.data!, username: username, password: password);
    }
    return ApiResult<bool>(
      data: true,
    );
  }

  Map<String, String> queries = {'format': 'json', 'method': 'pwg.session.login'};
  Map<String, String> fields = {'username': username, 'password': password};

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
      ApiResult<StatusModel> status = await sessionStatus();
      if (status.hasData) {
        savePreferences(status.data!, username: username, password: password);
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
    return ApiResult<bool>(
      data: false,
      error: ApiErrors.wrongServerUrl,
    );
  }
}

Future<ApiResult<StatusModel>> sessionStatus() async {
  Map<String, String> queries = {'format': 'json', 'method': 'pwg.session.getStatus'};

  try {
    Response response = await ApiClient.get(queryParameters: queries);
    var data = json.decode(response.data);
    if (data['stat'] == 'ok') {
      return ApiResult<StatusModel>(
        data: StatusModel.fromJson(data['result']),
      );
    }
    return ApiResult(
      error: ApiErrors.getStatusError,
    );
  } on DioError catch (e) {
    debugPrint(e.message);
    return ApiResult(
      error: ApiErrors.getStatusError,
    );
  } catch (e) {
    return ApiResult(
      error: ApiErrors.getStatusError,
    );
  }
}

void savePreferences(
  StatusModel status, {
  String? username,
  String? password,
}) async {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  storage.write(key: 'SERVER_USERNAME', value: username);
  storage.write(key: 'SERVER_PASSWORD', value: password);

  saveSettings();
  saveStatus(status);
}

Future<void> saveSettings() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getInt("SORT") == null) {
    prefs.setInt("SORT", 0);
  }
  if (prefs.getDouble("PORTRAIT_IMAGE_COUNT") == null) {
    prefs.setDouble("PORTRAIT_IMAGE_COUNT", 4);
  }
  if (prefs.getBool("SHOW_THUMBNAIL_TITLE") == null) {
    prefs.setBool("SHOW_THUMBNAIL_TITLE", false);
  }
  if (prefs.getBool("REMOVE_METADATA") == null) {
    prefs.setBool("REMOVE_METADATA", false);
  }
  if (prefs.getString('THUMBNAIL_SIZE') == null) {
    prefs.setString('THUMBNAIL_SIZE', 'medium');
  }
  if (prefs.getString('FULL_SCREEN_IMAGE_SIZE') == null) {
    prefs.setString('FULL_SCREEN_IMAGE_SIZE', 'medium');
  }
  if (prefs.getString('ALBUM_THUMBNAIL_SIZE') == null) {
    prefs.setString('ALBUM_THUMBNAIL_SIZE', 'medium');
  }
}

void saveStatus(StatusModel status) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('ACCOUNT_USERNAME', status.username);
  prefs.setString('USER_STATUS', status.status);
  prefs.setString('PWG_TOKEN', status.pwgToken);
  prefs.setString('VERSION', status.version);
  prefs.setStringList("AVAILABLE_SIZES", status.availableSizes);
  if (["admin", "webmaster"].contains(status.status)) {
    prefs.setBool("IS_USER_ADMIN", true);
    prefs.setInt('UPLOAD_FORM_CHUNK_SIZE', status.uploadFormChunkSize ?? 0);
    prefs.setString("FILE_TYPES", status.uploadFileTypes ?? '');
  } else {
    prefs.setBool("IS_USER_ADMIN", false);
  }
}

class StatusModel {
  String username;
  String status;
  String? theme;
  String language;
  String pwgToken;
  String charset;
  String? currentDatetime;
  String version;
  List<String> availableSizes;
  String? uploadFileTypes;
  int? uploadFormChunkSize;

  StatusModel.fromJson(Map<String, dynamic> json)
      : username = json['username'] ?? 'guest',
        status = json['status'] ?? 'guest',
        theme = json['theme'],
        language = json['language'] ?? 'en_US',
        pwgToken = json['pwg_token'] ?? '',
        charset = json['charset'] ?? 'utf-8',
        currentDatetime = json['current_datetime'],
        version = json['version'],
        availableSizes = json['available_sizes'].cast<String>(),
        uploadFileTypes = json['upload_file_types'],
        uploadFormChunkSize = json['upload_form_chunk_size'];
}
