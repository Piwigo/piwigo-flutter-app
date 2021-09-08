import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:piwigo_ng/views/UploadGalleryViewPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class API {
  static final API _singleton = API._internal();

  static Dio dio = Dio();
  static CookieJar cookieJar = CookieJar();
  static Uploader uploader;
  static SharedPreferences prefs;
  static FlutterLocalNotificationsPlugin localNotification;

  factory API() {
    return _singleton;
  }

  AppLocalizations strings(context) {
    return AppLocalizations.of(context);
  }

  API._internal();
}