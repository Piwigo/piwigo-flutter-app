import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/network/api_error.dart';
import 'package:piwigo_ng/services/preferences_service.dart';

import 'api_client.dart';
import 'authentication.dart';

Future<ApiResponse<List<AlbumModel>>> fetchAlbums(int albumID) async {
  final Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'pwg.categories.getList',
    'cat_id': albumID,
    'thumbnail_size': Preferences.getAlbumThumbnailSize,
  };

  try {
    if (await methodExist('community.categories.getList')) {
      queries['faked_by_community'] = false;
    }

    Response response = await ApiClient.get(
      queryParameters: queries,
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonAlbums =
          tryParseJson(response.data)['result']['categories'];
      List<AlbumModel> albums = List<AlbumModel>.from(jsonAlbums.map(
        (album) {
          bool canUpload =
              appPreferences.getBool(Preferences.isAdminKey) ?? false;
          album['can_upload'] = canUpload;
          return AlbumModel.fromJson(album);
        },
      ));

      if (await methodExist('community.categories.getList')) {
        ApiResponse communityResult = await fetchCommunityAlbums(albumID);
        if (!communityResult.hasData || communityResult.data!.isEmpty) {
          return ApiResponse<List<AlbumModel>>(
            data: albums,
          );
        }
        if (communityResult.hasData) {
          for (AlbumModel communityAlbum in communityResult.data) {
            int index =
                albums.indexWhere((album) => album.id == communityAlbum.id);
            if (index >= 0) {
              AlbumModel newAlbum = albums.elementAt(index);
              newAlbum.canUpload = true;
              albums[index] = newAlbum;
            } else {
              communityAlbum.canUpload = true;
              albums.add(communityAlbum);
            }
          }
        }
      }

      return ApiResponse<List<AlbumModel>>(
        data: albums,
      );
    }
  } on DioError catch (e) {
    debugPrint(e.message);
  } catch (e) {
    debugPrint("$e");
  }
  return ApiResponse(error: ApiErrors.fetchAlbumsError);
}

Future<ApiResponse<List<AlbumModel>>> fetchCommunityAlbums(int albumID) async {
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

      return ApiResponse<List<AlbumModel>>(
        data: albums,
      );
    }
  } on DioError catch (e) {
    debugPrint(e.message);
  } catch (e) {
    debugPrint("$e");
  }
  return ApiResponse(error: ApiErrors.fetchAlbumsError);
}

Future<ApiResponse<List<AlbumModel>>> getAlbumTree([int? startId]) async {
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

      return ApiResponse<List<AlbumModel>>(
        data: albums,
      );
    }
  } on DioError catch (e) {
    debugPrint(e.message);
  } catch (e) {
    debugPrint("$e");
    debugPrint("${(e as Error).stackTrace}");
  }
  return ApiResponse(error: ApiErrors.fetchAlbumListError);
}

Future<ApiResponse<bool>> addAlbum({
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
        return ApiResponse(error: ApiErrors.createAlbumError);
      }
      return ApiResponse(data: true);
    }
  } on DioError catch (e) {
    debugPrint(e.message);
  } catch (e) {
    debugPrint("$e");
  }
  return ApiResponse(error: ApiErrors.createAlbumError);
}

Future<ApiResponse<bool>> moveAlbum(int catId, int parentCatId) async {
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
        return ApiResponse(error: ApiErrors.moveAlbumError);
      }
      return ApiResponse(data: true);
    }
  } on DioError catch (e) {
    debugPrint("${e.message}");
  } catch (e) {
    debugPrint("$e");
  }
  return ApiResponse(error: ApiErrors.moveAlbumError);
}

Future<ApiResponse<bool>> editAlbum({
  required int albumId,
  String? name,
  String? description,
  AlbumStatus? status,
}) async {
  Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.categories.setInfo',
  };
  Map<String, dynamic> data = {
    'category_id': albumId,
  };
  if (name != null) data['name'] = name;
  if (description != null) data['comment'] = description;
  if (status != null) data['status'] = status.toJson();

  final FormData formData = FormData.fromMap(data);

  try {
    Response response = await ApiClient.post(
      queryParameters: queries,
      data: formData,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
      if (data['stat'] == 'fail') {
        debugPrint("$data");
        return ApiResponse(error: ApiErrors.editAlbumError);
      }
      print(data);
      return ApiResponse(data: true);
    }
  } on DioError catch (e) {
    debugPrint("${e.message}");
  } catch (e) {
    debugPrint("$e");
  }
  return ApiResponse(error: ApiErrors.editAlbumError);
}

Future<ApiResponse<bool>> deleteAlbum(
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
        return ApiResponse(error: ApiErrors.deleteAlbumError);
      }
      return ApiResponse(data: true);
    }
  } on DioError catch (e) {
    debugPrint("${e.message}");
  } catch (e) {
    debugPrint("$e");
  }
  return ApiResponse(error: ApiErrors.deleteAlbumError);
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
