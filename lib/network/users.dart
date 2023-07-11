import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/network/api_client.dart';
import 'package:piwigo_ng/network/api_error.dart';

Future<ApiResult<List<ImageModel>>> fetchFavorites(int page) async {
  Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'pwg.users.favorites.getList',
    'per_page': 100,
    'page': page,
  };

  try {
    Response response = await ApiClient.get(queryParameters: queries);

    if (response.statusCode == 200) {
      var jsonImages = json.decode(response.data)["result"]["images"];
      List<ImageModel> images = List<ImageModel>.from(
        jsonImages.map((image) => ImageModel.fromJson(image)),
      );

      return ApiResult<List<ImageModel>>(data: images);
    }
  } on DioError catch (e) {
    debugPrint('Fetch favorites: ${e.message}');
  } on Error catch (e) {
    debugPrint('Fetch favorites: ${e.stackTrace}');
  }
  return ApiResult(error: ApiErrors.fetchFavoritesError);
}

Future<int> addFavorites(List<ImageModel> imageList) async {
  int nbSuccess = 0;
  for (ImageModel image in imageList) {
    bool response = await addFavorite(image.id);
    if (response == true) {
      nbSuccess++;
    }
  }
  return nbSuccess;
}

Future<bool> addFavorite(int imageId) async {
  final Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'pwg.users.favorites.add',
    'image_id': imageId,
  };
  try {
    Response response = await ApiClient.get(
      queryParameters: queries,
    );

    if (response.statusCode == 200) {
      return true;
    }
  } on DioError catch (e) {
    debugPrint('Add favorite: ${e.message}');
  } on Error catch (e) {
    debugPrint('Add favorite: ${e.stackTrace}');
  }
  return false;
}

Future<int> removeFavorites(List<ImageModel> imageList) async {
  int nbSuccess = 0;
  for (ImageModel image in imageList) {
    bool response = await removeFavorite(image.id);
    if (response == true) {
      nbSuccess++;
    }
  }
  return nbSuccess;
}

Future<bool> removeFavorite(int imageId) async {
  final Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'pwg.users.favorites.remove',
    'image_id': imageId,
  };

  try {
    Response response = await ApiClient.get(
      queryParameters: queries,
    );

    if (response.statusCode == 200) {
      return true;
    }
  } on DioError catch (e) {
    debugPrint('Remove favorite: ${e.message}');
  } on Error catch (e) {
    debugPrint('Remove favorite: ${e.stackTrace}');
  }
  return false;
}
