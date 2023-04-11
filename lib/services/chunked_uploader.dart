import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class ChunkedUploader {
  final Dio _dio;

  ChunkedUploader(this._dio);

  Future<Response?> upload({
    required String filePath,
    required String path,
    required String contentType,
    required Map<String, dynamic> data,
    required Map<String, String> params,
    CancelToken? cancelToken,
    required int maxChunkSize,
    required Function(double) onUploadProgress,
    String method = 'POST',
  }) =>
      UploadRequest(_dio,
              filePath: filePath,
              path: path,
              contentType: contentType,
              params: params,
              method: method,
              data: data,
              cancelToken: cancelToken,
              maxChunkSize: maxChunkSize,
              onUploadProgress: onUploadProgress)
          .upload();

  static Future<String> generateMd5(Stream<List<int>> stream) async {
    return (await md5.bind(stream).first).toString();
  }
}

class UploadRequest {
  final Dio dio;
  final String filePath, fileName, path;
  final Map<String, String> params;
  final String method;
  final String contentType;
  final Map<String, dynamic> data;
  final CancelToken? cancelToken;
  final File _file;
  final Function(double) onUploadProgress;
  late int _maxChunkSize;
  late int _fileSize;

  UploadRequest(this.dio,
      {required this.filePath,
      required this.params,
      required this.contentType,
      required this.path,
      required this.method,
      required this.data,
      this.cancelToken,
      required this.onUploadProgress,
      required int maxChunkSize})
      : _file = File(filePath),
        fileName = basename(filePath) {
    _fileSize = _file.lengthSync();
    _maxChunkSize = min(_fileSize, maxChunkSize);
  }

  Future<Response?> upload() async {
    Response? finalResponse;
    String originalSum;
    List<String> chunkSums = [];
    originalSum = await ChunkedUploader.generateMd5(_file.openRead());
    for (int i = 0; i < _chunksCount; i++) {
      final start = _getChunkStart(i);
      final end = _getChunkEnd(i);
      final chunkStream = _getChunkStream(start, end);
      chunkSums.add(await ChunkedUploader.generateMd5(chunkStream));
    }

    for (int i = 0; i < _chunksCount; i++) {
      final start = _getChunkStart(i);
      final end = _getChunkEnd(i);
      final chunkStream = _getChunkStream(start, end);

      final formData = FormData.fromMap({
        'chunks': _chunksCount,
        'chunk': i,
        'chunk_sum': chunkSums[i],
        'original_sum': originalSum,
        'file': MultipartFile(chunkStream, end - start, filename: fileName),
        ...data
      });

      Response response = await dio.request(
        path,
        data: formData,
        queryParameters: params,
        cancelToken: cancelToken,
        options: Options(
          method: method,
          contentType: contentType,
          headers: _getHeaders(start, end),
        ),
        onSendProgress: (current, total) => _updateProgress(i, current, total),
      );

      if (response.data != null &&
          json.decode(response.data)?['result']?['id'] != null) {
        finalResponse = response;
      }
      debugPrint("[$i] $response");
    }
    return finalResponse;
  }

  Stream<List<int>> _getChunkStream(int start, int end) =>
      _file.openRead(start, end);

  _updateProgress(int chunkIndex, int chunkCurrent, int chunkTotal) {
    int totalUploadedSize = (chunkIndex * _maxChunkSize) + chunkCurrent;
    double totalUploadProgress = totalUploadedSize / _fileSize;
    onUploadProgress.call(totalUploadProgress);
  }

  int _getChunkStart(int chunkIndex) => chunkIndex * _maxChunkSize;

  int _getChunkEnd(int chunkIndex) =>
      min((chunkIndex + 1) * _maxChunkSize, _fileSize);

  Map<String, dynamic> _getHeaders(int start, int end) =>
      {'Content-Range': 'bytes $start-${end - 1}/$_fileSize'};

  int get _chunksCount => (_fileSize / _maxChunkSize).ceil();
}
