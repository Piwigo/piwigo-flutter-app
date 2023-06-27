import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:piwigo_ng/app.dart';
import 'package:piwigo_ng/components/snackbars.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    print("[${options.method}] ${options.queryParameters['method']}");
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    options.baseUrl =
        (await secureStorage.read(key: Preferences.serverUrlKey))!;
    if (Preferences.getEnableBasicAuth) {
      String? username =
          appPreferences.getString(Preferences.basicUsernameKey) ??
              await secureStorage.read(key: Preferences.usernameKey);
      String? password =
          appPreferences.getString(Preferences.basicPasswordKey) ??
              await secureStorage.read(key: Preferences.passwordKey);
      String basicAuth =
          "Basic ${base64.encode(utf8.encode('$username:$password'))}";
      options.headers['authorization'] = basicAuth;
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    debugPrint(
        "[${response.statusCode}] ${response.requestOptions.queryParameters['method']}");
    return super.onResponse(response, handler);
  }

  @override
  void onError(
    DioError err,
    ErrorInterceptorHandler handler,
  ) async {
    debugPrint(
        "[${err.response?.statusCode}] ${err.requestOptions.queryParameters['method']}");
    debugPrint('${err.error}\n${err.stackTrace}');
    if (err.error is HandshakeException) {
      HandshakeException handshakeError = err.error as HandshakeException;
      String? message = handshakeError.osError?.message;
      if (message != null && message.contains('CERTIFICATE_VERIFY_FAILED')) {
        // Invalid SSL
      }
    }
    switch (err.response?.statusCode) {
      case null:
        App.scaffoldMessengerKey.currentState?.showSnackBar(
          errorSnackBar(
            message: appStrings.internetErrorGeneral_title,
            icon: Icons.signal_wifi_connected_no_internet_4,
          ),
        );
        break;
    }
    return super.onError(err, handler);
  }
}
