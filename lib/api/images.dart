import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/api_error.dart';

import 'api_client.dart';

Future<ApiResult<List<ImageModel>>> fetchImages(String albumID, int page) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.categories.getImages",
    "cat_id": albumID,
    "per_page": "100",
    "page": page.toString(),
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
    return ApiResult(error: ApiErrors.fetchImagesError);
  } on DioError catch (e) {
    debugPrint(e.message);
    return ApiResult(error: ApiErrors.fetchImagesError);
  } on Error catch (e) {
    debugPrint('$e');
    return ApiResult(error: ApiErrors.fetchImagesError);
  }
}

Future<ApiResult<List<ImageModel>>> searchImages(String searchQuery) async {
  Map<String, String> query = {
    "format": "json",
    "method": "pwg.images.search",
    "query": searchQuery,
  };

  try {
    Response response = await ApiClient.get(queryParameters: query);

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.data);
      if (result['err'] == 1002) {
        return ApiResult<List<ImageModel>>(data: []);
      }
      print(result["result"]["images"]);
      final jsonImages = result["result"]["images"];
      List<ImageModel> images = List<ImageModel>.from(
        jsonImages.map((image) => ImageModel.fromJson(image)),
      );
      return ApiResult<List<ImageModel>>(data: images);
    } else {
      return ApiResult(
        error: ApiErrors.searchImagesError,
      );
    }
  } on DioError {
    return ApiResult(
      error: ApiErrors.searchImagesError,
    );
  }
}

class ImageModel {
  String id;
  int width;
  int height;
  int hit;
  String file;
  String name;
  String? comment;
  String? dateCreation;
  String? dateAvailable;
  String? pageUrl;
  String? elementUrl;
  Map<String, dynamic> derivatives;
  List<dynamic> categories;

  ImageModel.fromJson(Map<String, dynamic> json)
      : id = json['id'].toString(),
        width = json['width'] ?? 0,
        height = json['height'] ?? 0,
        hit = json['hit'] ?? 0,
        file = json['file'] ?? '',
        name = json['name'] ?? '',
        comment = json['comment'],
        dateCreation = json['date_creation'],
        dateAvailable = json['date_available'],
        pageUrl = json['page_url'],
        elementUrl = json['element_url'],
        derivatives = json['derivatives'] ?? {},
        categories = json['categories'] ?? [];
}
