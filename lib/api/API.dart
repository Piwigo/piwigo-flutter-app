import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:piwigo_ng/views/UploadGalleryViewPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class API {
  static final API _singleton = API._internal();
  static Dio dio = Dio();
  static CookieJar cookieJar = CookieJar();
  static Uploader uploader;
  static SharedPreferences prefs;
  factory API() {
    return _singleton;
  }

  API._internal();
}