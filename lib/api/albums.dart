import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/services/preferences_service.dart';

import 'api_client.dart';

Future<ApiResult<List<AlbumModel>>> fetchAlbums(int albumID) async {
  print(Preferences.getAlbumThumbnailSize);
  Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'pwg.categories.getList',
    'cat_id': albumID,
    'thumbnail_size': Preferences.getAlbumThumbnailSize,
  };

  try {
    Response response = await ApiClient.get(queryParameters: queries);

    if (response.statusCode == 200) {
      List<dynamic> jsonAlbums = json.decode(response.data)['result']['categories'];
      List<AlbumModel> albums = List<AlbumModel>.from(jsonAlbums.map(
        (album) => AlbumModel.fromJson(album),
      ));

      return ApiResult<List<AlbumModel>>(
        data: albums,
      );
    }
    return ApiResult(error: ApiErrors.fetchAlbumsError);
  } on DioError catch (e) {
    debugPrint(e.message);
    return ApiResult(error: ApiErrors.fetchAlbumsError);
  } catch (e) {
    debugPrint("$e");
    return ApiResult(error: ApiErrors.fetchAlbumsError);
  }
}

Future<ApiResult<Map<String, dynamic>>> getAlbumList() async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.categories.getAdminList",
  };

  try {
    Response response = await ApiClient.get(queryParameters: queries);

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      return ApiResult(error: ApiErrors.fetchAlbumListError);
    }
  } on DioError catch (e) {
    debugPrint(e.message);
    return ApiResult(error: ApiErrors.fetchAlbumListError);
  } catch (e) {
    debugPrint("$e");
    return ApiResult(error: ApiErrors.fetchAlbumListError);
  }
}
