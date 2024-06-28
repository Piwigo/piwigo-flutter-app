import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/models/tag_model.dart';
import 'package:piwigo_ng/network/api_error.dart';
import 'package:piwigo_ng/services/preferences_service.dart';

import 'api_client.dart';

Future<ApiResponse<List<TagModel>>> getTags() async {
  Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.tags.getList',
  };

  Response response = await ApiClient.get(queryParameters: queries);

  try {
    if (response.statusCode == 200) {
      var data = json.decode(response.data);
      if (data['stat'] == 'fail') {
        return ApiResponse(error: ApiErrors.error);
      }
      List<TagModel> tags = data['result']['tags'].map<TagModel>((tag) => TagModel.fromJson(tag)).toList();
      return ApiResponse(data: tags);
    }
  } on DioException catch (e) {
    debugPrint('Get tags: ${e.message}');
  } on Error catch (e) {
    debugPrint('Get tags: $e\n${e.stackTrace}');
  }
  return ApiResponse(error: ApiErrors.error);
}

Future<ApiResponse<List<TagModel>>> getAdminTags() async {
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
      List<TagModel> tags = data['result']['tags'].map<TagModel>((tag) => TagModel.fromJson(tag)).toList();
      return ApiResponse(data: tags);
    }
  } on DioException catch (e) {
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
  } on DioException catch (e) {
    debugPrint('Fetch tags: ${e.message}');
  } on Error catch (e) {
    debugPrint('Fetch tags: $e\n${e.stackTrace}');
  }
  return ApiResponse(error: ApiErrors.error);
}

Future<dynamic> editTag(int tagId, String tagName) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.tags.rename",
  };
  FormData formData = FormData.fromMap({
    "tag_id": tagId,
    "new_name": tagName,
    'pwg_token': appPreferences.getString('PWG_TOKEN'),
  });
  Response response = await ApiClient.post(data: formData, queryParameters: queries);

  try {
    if (response.statusCode == 200) {
      var data = json.decode(response.data);
      if (data['stat'] == 'fail') {
        return ApiResponse(error: ApiErrors.error);
      }
      return ApiResponse(data: true);
    }
  } on DioException catch (e) {
    debugPrint('Get tags: ${e.message}');
  } on Error catch (e) {
    debugPrint('Get tags: $e\n${e.stackTrace}');
  }
  return ApiResponse(error: ApiErrors.error);
}
