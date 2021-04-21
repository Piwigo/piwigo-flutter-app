

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class API {
  static final API _singleton = API._internal();
  static var dio = Dio();
  static var cookieJar = CookieJar();
  factory API() {
    return _singleton;
  }

  API._internal();
}