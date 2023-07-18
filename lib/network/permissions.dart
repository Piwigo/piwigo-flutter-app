import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/models/album_permission_model.dart';
import 'package:piwigo_ng/network/api_client.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AlbumPermissionModel?> getAlbumPermissions(
  int albumId,
) async {
  List<AlbumPermissionModel>? permissions =
      await getPermissions(byAlbum: albumId);
  if (permissions == null || permissions.isEmpty) {
    return null;
  }
  return permissions.single;
}

Future<List<AlbumPermissionModel>?> getUserPermissions(
  int userId,
) async {
  return getPermissions(byUser: userId);
}

Future<List<AlbumPermissionModel>?> getGroupPermissions(
  int groupId,
) async {
  return getPermissions(byGroup: groupId);
}

Future<List<AlbumPermissionModel>?> getPermissions({
  int? byAlbum,
  int? byUser,
  int? byGroup,
}) async {
  assert(!(byAlbum != null && byUser != null && byGroup != null));
  Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'pwg.permissions.getList',
  };

  if (byAlbum != null) queries['cat_id'] = byAlbum;
  if (byGroup != null) queries['group_id'] = byGroup;
  if (byUser != null) queries['user_id'] = byUser;

  try {
    Response response = await ApiClient.get(queryParameters: queries);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.data);
      var jsonPermissions = data['result']['categories'];
      List<AlbumPermissionModel> permissions = List<AlbumPermissionModel>.from(
        jsonPermissions
            .map((permission) => AlbumPermissionModel.fromJson(permission)),
      );

      return permissions;
    }
  } on DioError catch (e) {
    debugPrint('Fetch permissions: ${e.message}');
  } on Error catch (e) {
    debugPrint('Fetch permissions: ${e.stackTrace}');
  }
  return null;
}

Future<bool> addPermission({
  required int albumId,
  List<int>? users,
  List<int>? groups,
  bool? recursive,
}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'pwg.permissions.add',
  };

  Map<String, dynamic> body = {
    'cat_id': albumId,
    'pwg_token': prefs.getString(Preferences.tokenKey),
  };

  if (users != null) body['user_id'] = users;
  if (groups != null) body['group_id'] = groups;
  if (recursive != null) body['recursive'] = recursive;

  try {
    Response response = await ApiClient.post(
      queryParameters: queries,
      data: body,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.data);
      print(data);
      return true;
    }
  } on DioError catch (e) {
    debugPrint('Add permission: ${e.message}');
  } on Error catch (e) {
    debugPrint('Add permission: ${e.stackTrace}');
  }
  return false;
}

Future<bool> removePermission({
  required int albumId,
  List<int>? users,
  List<int>? groups,
}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'pwg.permissions.remove',
  };

  Map<String, dynamic> body = {
    'cat_id': albumId,
    'pwg_token': prefs.getString(Preferences.tokenKey),
  };

  if (users != null) body['user_id'] = users;
  if (groups != null) body['group_id'] = groups;

  try {
    Response response = await ApiClient.post(
      queryParameters: queries,
      data: body,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.data);
      print(data);
      return true;
    }
  } on DioError catch (e) {
    debugPrint('Add permission: ${e.message}');
  } on Error catch (e) {
    debugPrint('Add permission: ${e.stackTrace}');
  }
  return false;
}
