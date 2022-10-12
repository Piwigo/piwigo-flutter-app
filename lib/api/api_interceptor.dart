import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('[${options.method}] ${options.queryParameters['method']}');
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    options.baseUrl = (await secureStorage.read(key: 'SERVER_URL'))!;
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    print(
        '[${response.statusCode}] ${response.requestOptions.queryParameters['method']}');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    print(
        '[${err.response?.statusCode}] ${err.requestOptions.queryParameters['method']}');
    return super.onError(err, handler);
  }
}
