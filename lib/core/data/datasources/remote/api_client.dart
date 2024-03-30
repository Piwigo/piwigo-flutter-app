import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:piwigo_ng/core/data/datasources/local/preferences_datasource.dart';
import 'package:piwigo_ng/core/data/datasources/remote/api_interceptor.dart';
import 'package:piwigo_ng/core/utils/constants/local_key_constants.dart';

class ApiClient {
  ApiClient()
      : dio = Dio(BaseOptions())
          ..interceptors.add(ApiInterceptor())
          ..interceptors.add(CookieManager(CookieJar()));
  final Dio dio;
}

class SSLHttpOverrides extends HttpOverrides with AppPreferencesMixin {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = _badCertificateCallback;
  }

  bool _badCertificateCallback(X509Certificate cert, String host, int port) {
    if (prefs.instance.getBool(LocalKeyConstants.enableSSLKey) ?? false) {
      return true;
    }
    return false;
  }
}

Map<String, dynamic> tryParseJson(String data) {
  try {
    return json.decode(data);
  } on FormatException catch (_) {
    if (kDebugMode) {
      print('Invalid json data');
      print(data);
    }
    int start = data.indexOf('{');
    int end = data.lastIndexOf('}');
    String parsedData = data.substring(start, end + 1);
    if (kDebugMode) print("Parsed : $parsedData");
    return json.decode(parsedData);
  }
}
