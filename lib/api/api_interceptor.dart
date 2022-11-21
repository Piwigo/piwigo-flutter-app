import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:piwigo_ng/app.dart';
import 'package:piwigo_ng/components/snackbars.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    print('[${options.method}] ${options.queryParameters['method']}');
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    options.baseUrl = (await secureStorage.read(key: 'SERVER_URL'))!;
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    print('[${response.statusCode}] ${response.requestOptions.queryParameters['method']}');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    debugPrint('[${err.response?.statusCode}] ${err.requestOptions.queryParameters['method']}');
    debugPrint('${err.error}\n${err.stackTrace}');
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
