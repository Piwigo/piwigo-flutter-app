import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/models/info_model.dart';
import 'package:piwigo_ng/models/status_model.dart';
import 'package:piwigo_ng/network/api_error.dart';
import 'package:piwigo_ng/network/upload.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

Future<ApiResponse<String>> pingAPI() async {
  Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.getVersion',
  };

  try {
    Response response = await ApiClient.get(queryParameters: queries);
    var data = json.decode(response.data);
    if (data['stat'] == 'ok') {
      return ApiResponse<String>(data: data['result']);
    }
  } on DioException catch (e) {
    debugPrint(e.message);
  } catch (e) {
    debugPrint('Error $e');
  }
  return ApiResponse(error: ApiErrors.error);
}

Future<ApiResponse<bool>> loginUser(
  String url, {
  String username = '',
  String password = '',
}) async {
  if (url.isEmpty) {
    return ApiResponse<bool>(
      data: false,
      error: ApiErrors.wrongServerUrl,
    );
  }

  ApiClient.cookieJar.deleteAll();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(Preferences.serverUrlKey, url);

  if (username.isEmpty && password.isEmpty) {
    ApiResponse<StatusModel> status = await sessionStatus();
    if (!status.hasError && status.hasData) {
      Preferences.saveId(status.data!, username: username, password: password);
      return ApiResponse<bool>(
        data: true,
      );
    }
    askMediaPermission();
    return ApiResponse<bool>(
      data: false,
      // error: ApiErrors.wrongServerUrl,
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
        return ApiResponse<bool>(
          data: false,
          error: ApiErrors.wrongLoginId,
        );
      }
      ApiResponse<StatusModel> status = await sessionStatus();
      if (status.hasData) {
        Preferences.saveId(status.data!, username: username, password: password);
      }
      askMediaPermission();
      return ApiResponse<bool>(
        data: true,
      );
    }
  } on DioException catch (e) {
    debugPrint(e.message);
  } catch (e) {
    debugPrint('Error $e');
  }
  return ApiResponse<bool>(
    data: false,
    // error: ApiErrors.wrongServerUrl,
  );
}

Future<ApiResponse<StatusModel>> sessionStatus() async {
  Map<String, String> queries = {'format': 'json', 'method': 'pwg.session.getStatus'};

  try {
    Response response = await ApiClient.get(queryParameters: queries);
    var data = json.decode(response.data);
    if (data['stat'] == 'ok') {
      if (await methodExist('community.session.getStatus')) {
        String? community = await communityStatus();
        data['result']['real_user_status'] = community;
      }
      return ApiResponse<StatusModel>(
        data: StatusModel.fromJson(data['result']),
      );
    }
  } on DioException catch (e) {
    debugPrint(e.message);
  } catch (e) {
    debugPrint('Session Status Error: $e');
    if (e is Error) {
      debugPrint('${e.stackTrace}');
    }
  }
  return ApiResponse(
    error: ApiErrors.getStatusError,
  );
}

Future<String?> communityStatus() async {
  Map<String, String> queries = {'format': 'json', 'method': 'community.session.getStatus'};

  try {
    Response response = await ApiClient.get(queryParameters: queries);
    var data = json.decode(response.data);
    if (data['stat'] == 'ok') {
      return data['result']['real_user_status'];
    }
  } on DioException catch (e) {
    debugPrint(e.message);
  } catch (e) {
    debugPrint('Error $e');
  }
  return null;
}

Future<ApiResponse<InfoModel>> getInfo() async {
  Map<String, String> queries = {'format': 'json', 'method': 'pwg.getInfos'};

  try {
    Response response = await ApiClient.get(queryParameters: queries);
    var data = json.decode(response.data);
    if (data['stat'] == 'ok') {
      return ApiResponse<InfoModel>(
        data: InfoModel.fromJson(data['result']),
      );
    }
  } on DioException catch (e) {
    debugPrint(e.message);
  } catch (e) {
    debugPrint('Error $e');
  }
  return ApiResponse(
    error: ApiErrors.getInfoError,
  );
}

Future<ApiResponse<List<String>>> getMethods() async {
  Map<String, String> queries = {'format': 'json', 'method': 'reflection.getMethodList'};

  try {
    Response response = await ApiClient.get(queryParameters: queries);
    Map<String, dynamic> data = json.decode(response.data);
    final List<String> methods = data['result']['methods'].map<String>((e) => e.toString()).toList();
    return ApiResponse<List<String>>(data: methods);
  } on DioException catch (e) {
    debugPrint(e.message);
  } catch (e) {
    debugPrint('Error $e');
  }
  return ApiResponse<List<String>>(error: ApiErrors.getMethodsError);
}

Future<bool> methodExist(String method) async {
  var result = await getMethods();
  if (result.hasData) {
    return result.data!.contains(method);
  }
  return false;
}
