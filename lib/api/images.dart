import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/models/image_model.dart';

import 'api_client.dart';

Future<ApiResult<List<ImageModel>>> fetchImages(int albumID, int page) async {
  Map<String, dynamic> queries = {
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

Future<ApiResult<Map>> searchImages(String searchQuery, [int page = 0]) async {
  Map<String, dynamic> query = {
    "format": "json",
    "method": "pwg.images.search",
    "query": searchQuery,
    "page": page,
  };

  try {
    Response response = await ApiClient.get(queryParameters: query);

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.data);
      if (result['err'] == 1002) {
        return ApiResult<Map>(data: {
          "total_count": 0,
          "images": [],
        });
      }
      final jsonImages = result["result"]["images"];
      List<ImageModel> images = List<ImageModel>.from(
        jsonImages.map((image) => ImageModel.fromJson(image)),
      );
      return ApiResult<Map>(data: {
        "total_count": result["result"]["paging"]["total_count"],
        "images": images,
      });
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
