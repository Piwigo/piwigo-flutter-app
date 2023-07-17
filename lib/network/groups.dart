import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/models/group_model.dart';
import 'package:piwigo_ng/network/api_client.dart';
import 'package:piwigo_ng/utils/settings.dart';

import 'api_error.dart';

Future<ApiResponse<List<GroupModel>?>> getGroups([int page = 0]) async {
  Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'pwg.groups.getList',
    'order': Settings.defaultGroupSort,
    'per_page': Settings.defaultElementPerPage,
    'page': page,
  };

  try {
    Response response = await ApiClient.get(queryParameters: queries);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.data);
      var jsonGroups = data['result']['groups'];
      List<GroupModel> groups = List<GroupModel>.from(
        jsonGroups.map((group) => GroupModel.fromJson(group)),
      );

      return ApiResponse<List<GroupModel>?>(
        paging: PagingModel.fromJson(json: data['result']['paging']),
        data: groups,
      );
    }
  } on DioError catch (e) {
    debugPrint('Fetch groups: ${e.message}');
  } on Error catch (e) {
    debugPrint('Fetch groups: ${e.stackTrace}');
  }
  return ApiResponse<List<GroupModel>?>(
    error: ApiErrors.error,
  );
}
