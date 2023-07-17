import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/models/tag_model.dart';
import 'package:piwigo_ng/network/api_error.dart';

import 'api_client.dart';

Future<ApiResponse<List<TagModel>>> getTags() async {
  Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.tags.getAdminList',
  };

  Response response = await ApiClient.get(queryParameters: queries);

  try {
    if (response.statusCode == 200) {
      var data = json.decode(response.data);
      if (data['stat'] == 'fail') {
        return ApiResponse(error: ApiErrors.error);
      }
      List<TagModel> tags = data['result']['tags']
          .map<TagModel>((tag) => TagModel.fromJson(tag))
          .toList();
      return ApiResponse(data: tags);
    }
  } on DioError catch (e) {
    debugPrint('Get tags: ${e.message}');
  } on Error catch (e) {
    debugPrint('Get tags: $e\n${e.stackTrace}');
  }
  return ApiResponse(error: ApiErrors.error);
}

Future<ApiResponse<TagModel>> createTag(String name) async {
  Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.tags.add',
    'name': name,
  };
  Response response = await ApiClient.get(queryParameters: queries);

  try {
    if (response.statusCode == 200) {
      var data = json.decode(response.data);
      print(data);
      if (data['stat'] == 'fail') {
        return ApiResponse(error: ApiErrors.error);
      }
      return ApiResponse(
        data: TagModel.fromJson(data['result']),
      );
    }
  } on DioError catch (e) {
    debugPrint('Fetch tags: ${e.message}');
  } on Error catch (e) {
    debugPrint('Fetch tags: $e\n${e.stackTrace}');
  }
  return ApiResponse(error: ApiErrors.error);
}
