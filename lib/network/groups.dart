import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/models/group_model.dart';
import 'package:piwigo_ng/network/api_client.dart';
import 'package:piwigo_ng/utils/settings.dart';

import 'api_error.dart';

Future<List<GroupModel>?> getAllGroups({
  List<int>? groups,
  String? name,
}) async {
  int page = 0;
  bool reachedEnd = false;
  List<GroupModel> groupsResponse = [];

  Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'pwg.groups.getList',
    'order': Settings.defaultGroupSort,
    'per_page': Settings.defaultElementPerPage,
    'page': page,
  };

  if (groups != null) queries['group_id[]'] = groups;
  if (name != null) queries['name'] = "$name%";

  try {
    while (!reachedEnd) {
      Response response = await ApiClient.get(queryParameters: queries);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.data);

        var jsonGroups = data['result']['groups'];

        List<GroupModel> pageGroups = List<GroupModel>.from(
          jsonGroups.map((group) => GroupModel.fromJson(group)),
        );

        groupsResponse.addAll(pageGroups);

        if (pageGroups.length < Settings.defaultElementPerPage) {
          reachedEnd = true;
        } else {
          page++;
          queries['page'] = page;
        }
      } else {
        if (groupsResponse.isEmpty) {
          return null;
        }
        reachedEnd = true;
      }
    }

    return groupsResponse;
  } on DioError catch (e) {
    debugPrint('Fetch all groups: ${e.message}');
  } on Error catch (e) {
    debugPrint('Fetch all groups: ${e.stackTrace}');
  }
  return null;
}

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
