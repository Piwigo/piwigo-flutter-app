import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'api_interceptor.dart';

class ApiClient {
  static CookieJar cookieJar = CookieJar();
  static Dio dio = Dio(BaseOptions())
    ..interceptors.add(ApiInterceptor())
    ..interceptors.add(CookieManager(cookieJar))
    ..httpClientAdapter = sslHttpClientAdapter;

  static HttpClientAdapter get sslHttpClientAdapter {
    return DefaultHttpClientAdapter()
      ..onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback = piwigoSSLBypass;
        return client;
      };
  }

  static bool piwigoSSLBypass(X509Certificate cert, String host, int port) {
    // todo: accept certs
    return true;
  }

  static Future<Response> get({
    String path = 'ws.php',
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    Response response = await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  }

  static Future<Response> post({
    String path = 'ws.php',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    Response response = await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  }

  static Future<Response> put({
    String path = 'ws.php',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    Response response = await dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  }

  static Future<Response> delete({
    String path = 'ws.php',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    Response response = await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return response;
  }

  static Future<Response> download({
    required String path,
    required String outputPath,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String lengthHeader = Headers.contentLengthHeader,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    Response response = await dio.download(
      path,
      outputPath,
      data: data,
      queryParameters: queryParameters,
      options: options,
      lengthHeader: lengthHeader,
      cancelToken: cancelToken,
      deleteOnError: true,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  }
}

class SSLHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = ApiClient.piwigoSSLBypass;
  }
}
