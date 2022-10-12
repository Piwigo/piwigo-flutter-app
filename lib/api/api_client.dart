import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'api_interceptor.dart';

class ApiClient {
  // static final ApiClient _singleton = ApiClient._internal();

  // static PersistCookieJar cookieJar = PersistCookieJar();
  static CookieJar cookieJar = CookieJar();
  static Dio dio = Dio(BaseOptions())
    ..interceptors.add(ApiInterceptor())
    ..interceptors.add(CookieManager(cookieJar));

  // factory ApiClient() {
  //   return _singleton;
  // }

  void createDio() {
    dio = Dio(BaseOptions())
      ..interceptors.add(CookieManager(cookieJar))
      ..interceptors.add(ApiInterceptor());
  }

  // ApiClient._internal();

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
}
