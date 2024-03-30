import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/app.dart';
import 'package:piwigo_ng/components/snackbars.dart';
import 'package:piwigo_ng/core/data/datasources/local/preferences_datasource.dart';
import 'package:piwigo_ng/core/extensions/api_preferences_extension.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class ApiInterceptor extends Interceptor with AppPreferencesMixin {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    debugPrint('[${options.method}] ${options.queryParameters['method']}');
    try {
      options = _buildRequest(options);
      return super.onRequest(options, handler);
    } catch (error) {
      return handler.reject(
        DioError(
          error: error,
          requestOptions: options,
          type: DioErrorType.response,
        ),
      );
    }
  }

  RequestOptions _buildRequest(RequestOptions options) {
    // Get server url
    options.baseUrl = prefs.apiBaseUrl!;

    // Server needs Basic authorization
    options.headers['authorization'] = prefs.apiBasicHeader;

    return options;
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    debugPrint("[${response.statusCode}] ${response.requestOptions.queryParameters['method']}");
    return super.onResponse(response, handler);
  }

  @override
  void onError(
    DioError err,
    ErrorInterceptorHandler handler,
  ) async {
    debugPrint("[${err.response?.statusCode}] ${err.requestOptions.queryParameters['method']}");
    debugPrint('${err.error}\n${err.response?.data}\n${err.stackTrace}');

    switch (err.response?.statusCode) {
      case 403:
        App.scaffoldMessengerKey.currentState?.showSnackBar(
          errorSnackBar(
            message: appStrings.sessionStatusError_title,
            icon: Icons.block,
          ),
        );
        break;
      case null:
        // Handle invalid SSL
        if (err.error is HandshakeException) {
          HandshakeException handshakeError = err.error as HandshakeException;
          String? message = handshakeError.osError?.message;
          if (message != null && message.contains('CERTIFICATE_VERIFY_FAILED')) {
            App.scaffoldMessengerKey.currentState?.showSnackBar(
              errorSnackBar(
                message: appStrings.loginCertFailed_title,
                icon: Icons.bookmark_outlined,
              ),
            );
            break;
          }
        }

        // Handle invalid URL
        if (err.error is SocketException) {
          SocketException socketError = err.error as SocketException;
          int? code = socketError.osError?.errorCode;
          if (code == 7) {
            App.scaffoldMessengerKey.currentState?.showSnackBar(
              errorSnackBar(
                message: appStrings.serverURLerror_title,
                icon: Icons.public_off,
              ),
            );
            break;
          }
        }

        // Unknown server error
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
