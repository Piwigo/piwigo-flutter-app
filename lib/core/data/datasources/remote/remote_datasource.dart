import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:piwigo_ng/core/data/datasources/remote/api_client.dart';
import 'package:piwigo_ng/core/data/models/api_failure_model.dart';
import 'package:piwigo_ng/core/enum/request_format_enum.dart';
import 'package:piwigo_ng/core/errors/failures.dart';
import 'package:piwigo_ng/core/extensions/api_failure_mapper_extension.dart';
import 'package:piwigo_ng/core/injector/injector.dart';
import 'package:piwigo_ng/core/network/network_info.dart';
import 'package:piwigo_ng/core/utils/constants/api_constants.dart';
import 'package:piwigo_ng/core/utils/result.dart';

class RemoteDatasource {
  const RemoteDatasource();

  static final ApiClient _apiClient = serviceLocator();
  static const RequestFormatEnum _defaultRequestFormat = RequestFormatEnum.json;

  Map<String, dynamic> _buildQueries({
    required String method,
    RequestFormatEnum? format,
    Map<String, dynamic>? queryParameters,
  }) =>
      <String, dynamic>{
        'format': (format ?? _defaultRequestFormat).value,
        'method': method,
        if (queryParameters != null) ...queryParameters,
      };

  dynamic _buildData(
    Map<String, dynamic>? data,
  ) {
    if (data == null) return null;
    return FormData.fromMap(data);
  }

  Future<Result<T>> performRequest<T>(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      if (await serviceLocator<NetworkInfo>().isConnected) {
        Response<dynamic> response = await request();

        Map<String, dynamic> data = json.decode(response.data as String);
        if (data['stat'] == 'fail') {
          return Result<T>.failure(
            ApiFailureMapper.fromApiFailure(ApiFailureModel.fromJson(data)),
          );
        } else if (data['stat'] == 'ok') {
          return Result<T>.success(data['result']);
        }
        return Result<T>.failure(const Failure.unknown());
      } else {
        return Result<T>.failure(const Failure.connectivity());
      }
    } on DioError catch (error) {
      return Result<T>.failure(Failure.dio(error));
    }
  }

  Future<Result<T>> get<T>({
    String path = ApiConstants.webServiceUrl,
    required String method,
    RequestFormatEnum? format,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async =>
      performRequest<T>(
        () => _apiClient.dio.get(
          path,
          queryParameters: _buildQueries(
            format: format,
            method: method,
            queryParameters: queryParameters,
          ),
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        ),
      );

  Future<Result<T>> post<T>({
    String path = ApiConstants.webServiceUrl,
    required String method,
    RequestFormatEnum? format,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) =>
      performRequest(
        () => _apiClient.dio.post(
          path,
          data: _buildData(data),
          queryParameters: _buildQueries(
            format: format,
            method: method,
            queryParameters: queryParameters,
          ),
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        ),
      );

  Future<Result<T>> put<T>({
    String path = ApiConstants.webServiceUrl,
    required String method,
    RequestFormatEnum? format,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) =>
      performRequest(
        () => _apiClient.dio.put(
          path,
          data: data,
          queryParameters: _buildQueries(
            format: format,
            method: method,
            queryParameters: queryParameters,
          ),
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        ),
      );

  Future<Result<T>> delete<T>({
    String path = ApiConstants.webServiceUrl,
    required String method,
    RequestFormatEnum? format,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) =>
      performRequest(
        () => _apiClient.dio.delete(
          path,
          data: data,
          queryParameters: _buildQueries(
            format: format,
            method: method,
            queryParameters: queryParameters,
          ),
          options: options,
          cancelToken: cancelToken,
        ),
      );

  Future<Result<T>> download<T>({
    required String path,
    required String outputPath,
    required String method,
    RequestFormatEnum? format,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String lengthHeader = Headers.contentLengthHeader,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) =>
      performRequest(
        () => _apiClient.dio.download(
          path,
          outputPath,
          data: data,
          queryParameters: _buildQueries(
            format: format,
            method: method,
            queryParameters: queryParameters,
          ),
          options: options,
          lengthHeader: lengthHeader,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        ),
      );
}
