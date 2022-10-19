import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/models/image_model.dart';

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
  } on DioError catch (e) {
    debugPrint('fetch images: ${e.message}');
  } on Error catch (e) {
    debugPrint('fetch images: ${e.stackTrace}');
  } catch (e) {
    debugPrint('fetch images: $e');
  }
  return ApiResult(error: ApiErrors.fetchImagesError);
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
    }
  } on DioError catch (e) {
    debugPrint('search images: ${e.message}');
  } on Error catch (e) {
    debugPrint('search images: ${e.stackTrace}');
  } catch (e) {
    debugPrint('search images: $e');
  }
  return ApiResult(error: ApiErrors.searchImagesError);
}
