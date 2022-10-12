import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

Future<ApiResult<List<AlbumModel>>> fetchAlbums(String albumID) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.categories.getList',
    'cat_id': albumID,
    'thumbnail_size': prefs.getString('thumbnail_size') ?? 'xxlarge',
  };

  try {
    Response response = await ApiClient.get(queryParameters: queries);

    if (response.statusCode == 200) {
      List<dynamic> jsonAlbums = json.decode(response.data)['result']['categories'];
      print(jsonAlbums);
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
  } on Error catch (e) {
    print(e.stackTrace);
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
  }
}

class AlbumModel {
  String id;
  String name;
  String? comment;
  String url;
  String? urlRepresentative;
  String? permalink;
  String? status;
  String upperCategories;
  String? idUpperCategory;
  String globalRank;
  int nbImages;
  int nbTotalImages;
  int nbCategories;
  String? idRepresentative;
  String? dateLast;
  String? dateLastMax;

  AlbumModel.fromJson(Map<String, dynamic> json)
      : id = json['id'].toString(),
        name = json['name'] ?? '',
        comment = json['comment'],
        url = json['url'],
        urlRepresentative = json['tn_url'],
        permalink = json['permalink'],
        status = json['status'],
        upperCategories = json['uppercats'],
        idUpperCategory = json['id_uppercat'],
        globalRank = json['global_rank'],
        nbImages = json['nb_images'] ?? 0,
        nbTotalImages = json['total_nb_images'] ?? 0,
        nbCategories = json['nb_categories'] ?? 0,
        idRepresentative = json['representative_picture_id'],
        dateLast = json['date_last'],
        dateLastMax = json['max_date_last'];
}
