import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/services/notification_service.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/settings.dart';
import 'package:share_plus/share_plus.dart';

import 'albums.dart';
import 'api_client.dart';

Future<ApiResult<ImageModel>> getImage(int imageId) async {
  Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'pwg.images.getInfo',
    'image_id': imageId,
  };

  try {
    Response response = await ApiClient.get(queryParameters: queries);

    if (response.statusCode == 200) {
      var data = json.decode(response.data);
      if (data['stat'] == 'fail') {
        return ApiResult(error: ApiErrors.error);
      }
      var jsonImage = data['result'];
      ImageModel image = ImageModel.fromJson(jsonImage);
      return ApiResult<ImageModel>(data: image);
    }
  } on DioError catch (e) {
    debugPrint('Fetch images: ${e.message}');
  } on Error catch (e) {
    debugPrint('Fetch images: $e\n${e.stackTrace}');
  }
  return ApiResult(error: ApiErrors.error);
}

Future<ApiResult<List<ImageModel>>> fetchImages(int albumID, int page) async {
  Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'pwg.categories.getImages',
    'cat_id': albumID,
    'order': Preferences.getImageSort.value,
    'per_page': Settings.defaultElementPerPage,
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
    debugPrint('Fetch images: ${e.message}');
  } on Error catch (e) {
    debugPrint('Fetch images: ${e.stackTrace}');
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
    debugPrint('Search images: ${e.message}');
  } on Error catch (e) {
    debugPrint('Search images: ${e.stackTrace}');
  }
  return ApiResult(error: ApiErrors.searchImagesError);
}

Future<bool> _requestPermissions() async {
  var permission = await Permission.storage.status;
  if (permission != PermissionStatus.granted) {
    await Permission.storage.request();
    permission = await Permission.storage.status;
  }

  return permission == PermissionStatus.granted;
}

Future<String?> pickDirectoryPath() async {
  return await FilePicker.platform.getDirectoryPath();
}

Future<void> _showDownloadNotification({bool success = true, String? payload}) async {
  if (!Preferences.getDownloadNotification) return;
  final android = AndroidNotificationDetails(
    'piwigo-ng-download',
    'Piwigo NG Download',
    channelDescription: 'piwigo_ng',
    priority: Priority.defaultPriority,
    importance: Importance.defaultImportance,
  );
  await showLocalNotification(
    id: 0,
    title: success ? appStrings.downloadImageSuccess_title : appStrings.downloadImageFail_title,
    body: success ? appStrings.downloadImageSuccess_message : appStrings.deleteImageFail_message,
    details: android,
    payload: payload,
  );
}

Future<bool> share(List<ImageModel> images) async {
  List<XFile>? filesPath = await downloadImages(
    images,
    showNotification: false,
    cached: true,
  );
  print(filesPath);
  if (filesPath == null || filesPath.isEmpty) return false;
  try {
    Share.shareXFiles(filesPath);
    return true;
  } catch (e) {
    debugPrint("$e");
  }
  return false;
}

Future<List<XFile>?> downloadImages(
  List<ImageModel> images, {
  bool showNotification = true,
  bool cached = false,
}) async {
  String? dirPath = (await getTemporaryDirectory()).path;
  if (!cached) {
    dirPath = await Preferences.getDownloadDestination;
  }

  if (dirPath == null) return null;
  final List<XFile> files = [];

  await Future.forEach(images, (ImageModel image) async {
    XFile? file = await downloadImage(dirPath!, image);
    if (file != null) {
      files.add(file);
    }
  });

  if (showNotification && Preferences.getDownloadNotification) {
    if (files.isNotEmpty) {
      await _showDownloadNotification(
        success: true,
        payload: files.length == 1 ? files.single.path : '$dirPath\\',
      );
    } else {
      await _showDownloadNotification(success: false);
    }
  }
  return files;
}

Future<XFile?> downloadImage(String dirPath, ImageModel image) async {
  String localPath = path.join(dirPath, image.file);
  try {
    await ApiClient.download(
      path: image.derivatives.medium.url,
      outputPath: localPath,
    );
    return XFile(localPath);
  } on DioError catch (e) {
    debugPrint('Download images: ${e.message}');
  } on Error catch (e) {
    debugPrint('Download images: ${e.stackTrace}');
  }
  return null;
}

Future<int> deleteImages(
  List<ImageModel> imageList,
  AlbumModel album,
  DeleteAlbumModes mode,
) async {
  int nbSuccess = 0;
  for (ImageModel image in imageList) {
    bool response = false;
    switch (mode) {
      case DeleteAlbumModes.noDelete:
        response = await removeImage(image, album.id);
        break;
      default:
        response = await deleteImage(image);
        break;
    }
    if (response == true) {
      nbSuccess++;
    }
  }
  return nbSuccess;
}

Future<bool> deleteImage(ImageModel image) async {
  Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.images.delete',
  };
  FormData formData = FormData.fromMap({
    'image_id': image.id,
    'pwg_token': appPreferences.getString(Preferences.tokenKey),
  });
  try {
    Response response = await ApiClient.post(
      data: formData,
      queryParameters: queries,
    );

    if (response.statusCode == 200) {
      return true;
    }
  } on DioError catch (e) {
    debugPrint('Delete images: ${e.message}');
  } on Error catch (e) {
    debugPrint('Delete images: ${e.stackTrace}');
  }
  return false;
}

Future<int> removeImages(List<ImageModel> images, int albumId) async {
  int nbSuccess = 0;
  for (ImageModel image in images) {
    bool response = await removeImage(image, albumId);
    if (response == true) {
      nbSuccess++;
    }
  }
  return nbSuccess;
}

Future<bool> removeImage(ImageModel image, int albumId) async {
  final List<int> albums = image.categories.map<int>((album) => album['id']).toList();
  albums.removeWhere((album) => album == albumId);

  if (albums.isEmpty) {
    deleteImage(image);
  }

  final Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'pwg.images.setInfo',
  };
  final FormData formData = FormData.fromMap({
    'image_id': image.id,
    'categories': albums,
    'multiple_value_mode': 'replace',
  });

  try {
    Response response = await ApiClient.post(data: formData, queryParameters: queries);

    if (response.statusCode == 200) {
      return true;
    }
  } on DioError catch (e) {
    debugPrint('Remove images: ${e.message}');
  } on Error catch (e) {
    debugPrint('Remove images: ${e.stackTrace}');
  }
  return false;
}

Future<int> moveImages(List<ImageModel> images, int oldAlbumId, int newAlbumId) async {
  int nbMoved = 0;
  for (var image in images) {
    bool response = await moveImage(image, oldAlbumId, newAlbumId);
    if (response) {
      nbMoved++;
    }
  }
  return nbMoved;
}

Future<bool> moveImage(ImageModel image, int oldAlbumId, int newAlbumId) async {
  final List<int> albums = image.categories.map<int>((album) => album['id']).toList();
  albums.removeWhere((id) => id == oldAlbumId);
  albums.add(newAlbumId);
  Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.images.setInfo',
  };

  FormData formData = FormData.fromMap({
    'image_id': image.id,
    'categories': albums,
    'multiple_value_mode': 'replace',
  });

  try {
    Response response = await ApiClient.post(data: formData, queryParameters: queries);

    if (response.statusCode == 200) {
      return true;
    }
  } on DioError catch (e) {
    debugPrint('Move images: ${e.message}');
  } on Error catch (e) {
    debugPrint('Move images: ${e.stackTrace}');
  }
  return false;
}

Future<int> assignImages(List<ImageModel> images, int albumId) async {
  int nbAssigned = 0;
  for (ImageModel image in images) {
    final List<int> categories = image.categories.map<int>((album) => album['id']).toList();
    categories.add(albumId);
    bool response = await assignImage(image.id, categories);
    if (response == true) {
      nbAssigned++;
    }
  }
  return nbAssigned;
}

Future<bool> assignImage(int imageId, List<int> categories) async {
  final Map<String, dynamic> queries = {
    'format': 'json',
    'method': 'pwg.images.setInfo',
  };

  final FormData formData = FormData.fromMap({
    'image_id': imageId,
    'categories': categories,
    'multiple_value_mode': 'append',
  });

  try {
    Response response = await ApiClient.post(data: formData, queryParameters: queries);

    if (response.statusCode == 200) {
      return true;
    }
  } on DioError catch (e) {
    debugPrint('Assign images: ${e.message}');
  } on Error catch (e) {
    debugPrint('Assign images: ${e.stackTrace}');
  }
  return false;
}

Future<int> editImages(List<ImageModel> images, [Map<String, dynamic> info = const {}]) async {
  int nbEdited = 0;
  for (ImageModel image in images) {
    bool response = await editImage(image, info);
    if (response == true) {
      nbEdited++;
    }
  }
  return nbEdited;
}

Future<bool> editImage(ImageModel image, [Map<String, dynamic> info = const {}]) async {
  final Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.images.setInfo',
  };
  Map<String, dynamic> form = {
    'image_id': image.id,
    'single_value_mode': 'replace',
    'multiple_value_mode': 'append',
  };
  if (info['title'] != null) form['name'] = info['title'];
  if (info['description'] != null) form['comment'] = info['description'];
  if (info['author'] != null) form['author'] = info['author'];
  if (info['level'] != null) form['level'] = info['level'];
  if (info['tags'] != null) form['tag_ids'] = info['tags'];

  final FormData formData = FormData.fromMap(form);

  try {
    Response response = await ApiClient.post(data: formData, queryParameters: queries);

    if (response.statusCode == 200) {
      return true;
    }
  } on DioError catch (e) {
    debugPrint('Edit images: ${e.message}');
  } on Error catch (e) {
    debugPrint('Edit images: ${e.stackTrace}');
  }
  return false;
}
