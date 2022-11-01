import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/models/info_model.dart';
import 'package:piwigo_ng/models/status_model.dart';
import 'package:piwigo_ng/services/preferences_service.dart';

import 'api_client.dart';

Future<ApiResult<bool>> loginUser(String url, String username, String password) async {
  if (url.isEmpty) {
    return ApiResult<bool>(
      data: false,
      error: ApiErrors.wrongServerUrl,
    );
  }
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  await secureStorage.write(key: 'SERVER_URL', value: url);

  if (username.isEmpty && password.isEmpty) {
    ApiResult<StatusModel> status = await sessionStatus();
    if (status.hasData) {
      Preferences.saveId(status.data!, username: username, password: password);
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
        Preferences.saveId(status.data!, username: username, password: password);
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
  } on DioError catch (e) {
    debugPrint(e.message);
  } catch (e) {
    debugPrint('Error $e');
  }
  return ApiResult(
    error: ApiErrors.getStatusError,
  );
}

Future<ApiResult<InfoModel>> getInfo() async {
  Map<String, String> queries = {'format': 'json', 'method': 'pwg.getInfos'};

  try {
    Response response = await ApiClient.get(queryParameters: queries);
    var data = json.decode(response.data);
    if (data['stat'] == 'ok') {
      return ApiResult<InfoModel>(
        data: InfoModel.fromJson(data['result']),
      );
    }
  } on DioError catch (e) {
    debugPrint(e.message);
  } catch (e) {
    debugPrint('Error $e');
  }
  return ApiResult(
    error: ApiErrors.getInfoError,
  );
}

Future<ApiResult<List<String>>> getMethods() async {
  Map<String, String> queries = {'format': 'json', 'method': 'reflection.getMethodList'};

  try {
    Response response = await ApiClient.get(queryParameters: queries);
    Map<String, dynamic> data = json.decode(response.data);
    final List<String> methods = data['result']['methods'].map<String>((e) => e.toString()).toList();
    return ApiResult<List<String>>(data: methods);
  } on DioError catch (e) {
    debugPrint(e.message);
  } catch (e) {
    debugPrint('Error $e');
  }
  return ApiResult<List<String>>(error: ApiErrors.getMethodsError);
}

Future<bool> methodExist(String method) async {
  var result = await getMethods();
  if (result.hasData) {
    return result.data!.contains(method);
  }
  return false;
}
