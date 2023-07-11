import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/network/api_error.dart';
import 'package:piwigo_ng/services/preferences_service.dart';

import 'api_client.dart';
import 'authentication.dart';

Map<String, dynamic> tryParseJson(String data) {
  try {
    return json.decode(data);
  } on FormatException catch (_) {
    debugPrint('Invalid json data');
    debugPrint(data);
    int start = data.indexOf('{');
    int end = data.lastIndexOf('}');
    String parsedData = data.substring(start, end + 1);
    return json.decode(parsedData);
  }
}

Future<ApiResult<List<AlbumModel>>> fetchAlbums(int albumID) async {
  final Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'pwg.categories.getList',
    'cat_id': albumID,
    'thumbnail_size': Preferences.getAlbumThumbnailSize,
  };

  try {
    List<String> uploadCategoryIdList = [];
    if (await methodExist('community.categories.getList')) {
      queries['faked_by_community'] = false;
      ApiResult communityResult = await fetchCommunityAlbums(albumID);
      if (communityResult.hasData) {
        uploadCategoryIdList = communityResult.data.map<String>(
          (cat) {
            return cat.id.toString();
          },
        ).toList();
      }
    }

    Response response = await ApiClient.get(
      queryParameters: queries,
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonAlbums =
          tryParseJson(response.data)['result']['categories'];
      List<AlbumModel> albums = List<AlbumModel>.from(jsonAlbums.map(
        (album) {
          bool canUpload = false;
          if ((appPreferences.getBool(Preferences.isAdminKey) ?? false) ||
              uploadCategoryIdList.contains(album['id'].toString())) {
            canUpload = true;
          }
          album['can_upload'] = canUpload;
          return AlbumModel.fromJson(album);
        },
      ));
      return ApiResult<List<AlbumModel>>(
        data: albums,
      );
    }
  } on DioError catch (e) {
    debugPrint(e.message);
  } catch (e) {
    debugPrint("$e");
  }
  return ApiResult(error: ApiErrors.fetchAlbumsError);
}

Future<ApiResult<List<AlbumModel>>> fetchCommunityAlbums(int albumID) async {
  final Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'community.categories.getList',
    'cat_id': albumID,
  };

  try {
    Response response = await ApiClient.get(
      queryParameters: queries,
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonAlbums =
          json.decode(response.data)['result']['categories'];
      List<AlbumModel> albums = List<AlbumModel>.from(jsonAlbums.map(
        (album) => AlbumModel.fromJson(album),
      ));

      return ApiResult<List<AlbumModel>>(
        data: albums,
      );
    }
  } on DioError catch (e) {
    debugPrint(e.message);
  } catch (e) {
    debugPrint("$e");
  }
  return ApiResult(error: ApiErrors.fetchAlbumsError);
}

Future<ApiResult<List<AlbumModel>>> getAlbumTree([int? startId]) async {
  final Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'pwg.categories.getList',
    'cat_id': startId ?? 0,
    'recursive': true,
    'tree_output': true,
    'thumbnail_size': Preferences.getAlbumThumbnailSize,
  };

  try {
    Response response = await ApiClient.get(
      queryParameters: queries,
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonAlbums = json.decode(response.data)['result'];
      List<AlbumModel> albums = List<AlbumModel>.from(jsonAlbums.map(
        (album) => AlbumModel.fromJson(album),
      ));

      return ApiResult<List<AlbumModel>>(
        data: albums,
      );
    }
  } on DioError catch (e) {
    debugPrint(e.message);
  } catch (e) {
    debugPrint("$e");
    debugPrint("${(e as Error).stackTrace}");
  }
  return ApiResult(error: ApiErrors.fetchAlbumListError);
}

Future<ApiResult<bool>> addAlbum({
  required String name,
  required int parentId,
  String description = '',
}) async {
  final Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'pwg.categories.add',
    'name': name,
    'comment': description,
    'parent': parentId,
  };

  try {
    Response response = await ApiClient.post(
      queryParameters: queries,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
      if (data['stat'] == 'fail') {
        debugPrint("$data");
        return ApiResult(error: ApiErrors.createAlbumError);
      }
      return ApiResult(data: true);
    }
  } on DioError catch (e) {
    debugPrint(e.message);
  } catch (e) {
    debugPrint("$e");
  }
  return ApiResult(error: ApiErrors.createAlbumError);
}

Future<ApiResult<bool>> moveAlbum(int catId, int parentCatId) async {
  final Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.categories.move',
  };

  final FormData formData = FormData.fromMap({
    'category_id': catId,
    'parent': parentCatId,
    'pwg_token': appPreferences.getString('PWG_TOKEN'),
  });

  try {
    Response response = await ApiClient.post(
      data: formData,
      queryParameters: queries,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
      if (data['stat'] == 'fail') {
        return ApiResult(error: ApiErrors.moveAlbumError);
      }
      return ApiResult(data: true);
    }
  } on DioError catch (e) {
    debugPrint("${e.message}");
  } catch (e) {
    debugPrint("$e");
  }
  return ApiResult(error: ApiErrors.moveAlbumError);
}

Future<ApiResult<bool>> editAlbum(
    {required String name,
    required int albumId,
    String description = ''}) async {
  Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.categories.setInfo',
  };
  FormData formData = FormData.fromMap({
    'category_id': albumId,
    'name': name,
    'comment': description,
  });

  try {
    Response response = await ApiClient.post(
      data: formData,
      queryParameters: queries,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
      if (data['stat'] == 'fail') {
        debugPrint("$data");
        return ApiResult(error: ApiErrors.editAlbumError);
      }
      return ApiResult(data: true);
    }
  } on DioError catch (e) {
    debugPrint("${e.message}");
  } catch (e) {
    debugPrint("$e");
  }
  return ApiResult(error: ApiErrors.editAlbumError);
}

Future<ApiResult<bool>> deleteAlbum(
  int catId, {
  DeleteAlbumModes deletionMode = DeleteAlbumModes.deleteOrphans,
}) async {
  final Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.categories.delete',
  };

  final FormData formData = FormData.fromMap({
    'category_id': catId,
    'pwg_token': appPreferences.getString('PWG_TOKEN'),
    'photo_deletion_mode': deletionMode.value,
  });

  try {
    Response response = await ApiClient.post(
      data: formData,
      queryParameters: queries,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
      if (data['stat'] == 'fail') {
        debugPrint("$data");
        return ApiResult(error: ApiErrors.deleteAlbumError);
      }
      return ApiResult(data: true);
    }
  } on DioError catch (e) {
    debugPrint("${e.message}");
  } catch (e) {
    debugPrint("$e");
  }
  return ApiResult(error: ApiErrors.deleteAlbumError);
}

enum DeleteAlbumModes {
  noDelete,
  deleteOrphans,
  forceDelete,
}

extension DeleteAlbumModesExtention on DeleteAlbumModes {
  String get value {
    switch (this) {
      case DeleteAlbumModes.noDelete:
        return 'no_delete';
      case DeleteAlbumModes.deleteOrphans:
        return 'delete_orphans';
      case DeleteAlbumModes.forceDelete:
        return 'force_delete';
    }
  }
}
