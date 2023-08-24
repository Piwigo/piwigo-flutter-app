import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:extended_text/extended_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/network/api_error.dart';
import 'package:piwigo_ng/services/chunked_uploader.dart';
import 'package:piwigo_ng/services/notification_service.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/settings.dart';
import 'package:share_plus/share_plus.dart';

import 'albums.dart';
import 'api_client.dart';

Future<ApiResponse<ImageModel>> getImage(
  int imageId,
) async {
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
        return ApiResponse(error: ApiErrors.error);
      }
      var jsonImage = data['result'];
      ImageModel image = ImageModel.fromJson(jsonImage);
      return ApiResponse<ImageModel>(data: image);
    }
  } on DioError catch (e) {
    debugPrint('Fetch images: ${e.message}');
  } on Error catch (e) {
    debugPrint('Fetch images: $e\n${e.stackTrace}');
  }
  return ApiResponse(error: ApiErrors.error);
}

Future<ApiResponse<List<ImageModel>>> fetchImages(
  int albumID, [
  int page = 0,
]) async {
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
      var jsonImages = tryParseJson(response.data)['result']['images'];
      List<ImageModel> images = List<ImageModel>.from(
        jsonImages.map((image) => ImageModel.fromJson(image)),
      );

      return ApiResponse<List<ImageModel>>(data: images);
    }
  } on DioError catch (e) {
    debugPrint('Fetch images: ${e.message}');
  } catch (e) {
    debugPrint('Fetch images: $e');
  }
  return ApiResponse(error: ApiErrors.fetchImagesError);
}

Future<ApiResponse<Map>> searchImages(
  String searchQuery, [
  int page = 0,
]) async {
  Map<String, dynamic> query = {
    'format': 'json',
    'method': 'pwg.images.search',
    'query': searchQuery,
    'order': Preferences.getImageSort.value,
    'per_page': Settings.defaultElementPerPage,
    'page': page,
  };

  try {
    Response response = await ApiClient.get(queryParameters: query);

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.data);
      if (result['err'] == 1002) {
        return ApiResponse<Map>(data: {
          'total_count': 0,
          'images': [],
        });
      }
      final jsonImages = result['result']['images'];
      List<ImageModel> images = List<ImageModel>.from(
        jsonImages.map((image) => ImageModel.fromJson(image)),
      );
      return ApiResponse<Map>(data: {
        'total_count': result['result']['paging']['total_count'],
        'images': images,
      });
    }
  } on DioError catch (e) {
    debugPrint('Search images: ${e.message}');
  } on Error catch (e) {
    debugPrint('Search images: ${e.stackTrace}');
  }
  return ApiResponse(error: ApiErrors.searchImagesError);
}

Future<ApiResponse<Map>> fetchFavorites([
  int page = 0,
]) async {
  Map<String, dynamic> query = {
    'format': 'json',
    'method': 'pwg.users.favorites.getList',
    'order': Preferences.getImageSort.value,
    'per_page': Settings.defaultElementPerPage,
    'page': page,
  };

  try {
    Response response = await ApiClient.get(queryParameters: query);

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.data);
      if (result['stat'] == 'fail') {
        return ApiResponse<Map>(data: {
          'total_count': 0,
          'images': [],
        });
      }
      final jsonImages = result['result']['images'];
      List<ImageModel> images = List<ImageModel>.from(
        jsonImages.map((image) {
          image['is_favorite'] = true;
          return ImageModel.fromJson(image);
        }),
      );
      return ApiResponse<Map>(data: {
        'total_count': result['result']['paging']['count'],
        'images': images,
      });
    }
  } on DioError catch (e) {
    debugPrint('Fetch favorites: ${e.message}');
  } on Error catch (e) {
    debugPrint('Fetch favorites: ${e.stackTrace}');
  }
  return ApiResponse(error: ApiErrors.error);
}

Future<String?> pickDirectoryPath() async {
  return await FilePicker.platform.getDirectoryPath();
}

Future<void> _showDownloadNotification({
  bool success = true,
  String? payload,
}) async {
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
    title: success
        ? appStrings.downloadImageSuccess_title
        : appStrings.downloadImageFail_title,
    body: success
        ? appStrings.downloadImageSuccess_message
        : appStrings.deleteImageFail_message,
    details: android,
    payload: payload,
  );
}

Future<bool> share(
  List<ImageModel> images,
) async {
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
    dirPath = Preferences.getDownloadDestination ?? await pickDirectoryPath();
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

Future<XFile?> downloadImage(
  String dirPath,
  ImageModel image,
) async {
  String localPath = path.join(dirPath, image.file);
  try {
    await ApiClient.download(
      path: image.elementUrl,
      outputPath: localPath,
    );
    return XFile(localPath);
  } on DioError catch (e) {
    debugPrint("Download images: ${e.message}");
  } on Error catch (e) {
    debugPrint("Download images: ${e.stackTrace}");
  }
  return null;
}

Future<int> deleteImages(
  List<ImageModel> imageList,
  AlbumModel? album,
  DeleteAlbumModes mode,
) async {
  int nbSuccess = 0;
  for (ImageModel image in imageList) {
    bool response = false;
    if (album == null) {
      response = await deleteImage(image);
    } else {
      switch (mode) {
        case DeleteAlbumModes.noDelete:
          response = await removeImage(image, album.id);
          break;
        default:
          response = await deleteImage(image);
          break;
      }
    }
    if (response == true) {
      nbSuccess++;
    }
  }
  return nbSuccess;
}

Future<bool> deleteImage(
  ImageModel image,
) async {
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

Future<int> removeImages(
  List<ImageModel> images,
  int albumId,
) async {
  int nbSuccess = 0;
  for (ImageModel image in images) {
    bool response = await removeImage(image, albumId);
    if (response == true) {
      nbSuccess++;
    }
  }
  return nbSuccess;
}

Future<bool> removeImage(
  ImageModel image,
  int albumId,
) async {
  final List<int> albums =
      image.categories.map<int>((album) => album['id']).toList();
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
    Response response =
        await ApiClient.post(data: formData, queryParameters: queries);

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

Future<int> moveImages(
  List<ImageModel> images,
  int oldAlbumId,
  int newAlbumId,
) async {
  int nbMoved = 0;
  for (var image in images) {
    bool response = await moveImage(image, oldAlbumId, newAlbumId);
    if (response) {
      nbMoved++;
    }
  }
  return nbMoved;
}

Future<bool> moveImage(
  ImageModel image,
  int oldAlbumId,
  int newAlbumId,
) async {
  final List<int> albums =
      image.categories.map<int>((album) => album['id']).toList();
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
    Response response =
        await ApiClient.post(data: formData, queryParameters: queries);

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

Future<int> assignImages(
  List<ImageModel> images,
  int albumId,
) async {
  int nbAssigned = 0;
  for (ImageModel image in images) {
    final List<int> categories =
        image.categories.map<int>((album) => album['id']).toList();
    categories.add(albumId);
    bool response = await assignImage(image.id, categories);
    if (response == true) {
      nbAssigned++;
    }
  }
  return nbAssigned;
}

Future<bool> assignImage(
  int imageId,
  List<int> categories,
) async {
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
    Response response =
        await ApiClient.post(data: formData, queryParameters: queries);

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

Future<int> editImages(
  List<ImageModel> images, [
  Map<String, dynamic> info = const {},
]) async {
  int nbEdited = 0;
  for (ImageModel image in images) {
    bool response = await editImage(
      image,
      info: info,
      single: images.length == 1,
    );
    if (response == true) {
      nbEdited++;
    }
  }
  return nbEdited;
}

Future<bool> editImage(
  ImageModel image, {
  Map<String, dynamic> info = const {},
  bool single = true,
}) async {
  final Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.images.setInfo',
  };
  Map<String, dynamic> form = {
    'image_id': image.id,
    'single_value_mode': 'replace',
    'multiple_value_mode': single ? 'replace' : 'append',
  };
  if (info['title'] != null) form['name'] = info['title'];
  if (info['description'] != null) form['comment'] = info['description'];
  if (info['author'] != null) form['author'] = info['author'];
  if (info['level'] != null) form['level'] = info['level'];
  if (info['tags'] != null) form['tag_ids'] = info['tags'];

  final FormData formData = FormData.fromMap(form);

  print(formData.fields);

  try {
    Response response = await ApiClient.post(
      data: formData,
      queryParameters: queries,
    );

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

/// Return a list of files that are not in the server
Future<List<File>> checkImagesNotExist(
  List<File> files, {
  bool returnExistFiles = false,
}) async {
  Map<String, File> md5sumList = {};

  for (File file in files) {
    String md5sum = await ChunkedUploader.generateMd5(file.openRead());
    md5sumList[md5sum] = file;
  }

  final Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.images.exist',
    'md5sum_list': md5sumList.keys.join(','),
  };

  try {
    Response response = await ApiClient.get(
      queryParameters: queries,
    );

    Map<String, dynamic> data = json.decode(response.data);
    if (data['stat'] == 'fail') return [];
    print(data['result']);
    Map<String, dynamic> existResult = data['result'];
    if (returnExistFiles) {
      existResult.removeWhere((key, value) => value == null);
    } else {
      existResult.removeWhere((key, value) => value != null);
    }
    return existResult.keys.map((md5sum) => md5sumList[md5sum]!).toList();
  } on DioError catch (e) {
    debugPrint('Edit images: ${e.message}');
  } on Error catch (e) {
    debugPrint('Edit images: ${e.stackTrace}');
  }
  return [];
}

String? removeUrlProtocol(String? url) {
  if (url == null) return null;
  url = url.replaceFirst('http://', '');
  url = url.replaceFirst('https://', '');
  return url;
}

String? cleanImageUrl(String? originalUrl) {
  if (originalUrl == null) return null;
  final String okUrl = originalUrl;

  // TEMPORARY PATCH for case where $conf['original_url_protection'] = 'images';
  /// See https://github.com/Piwigo/Piwigo-Mobile/issues/503
  String patchedUrl = okUrl.replaceAll('&amp;part=', '&part=');

  // Servers may return incorrect URLs
  /// See https://tools.ietf.org/html/rfc3986#section-2
  Uri? serverUrl = Uri.tryParse(patchedUrl);

  if (serverUrl == null) {
    // URL not RFC compliant!
    String leftUrl = patchedUrl;

    // Remove protocol header
    leftUrl = removeUrlProtocol(patchedUrl) ?? leftUrl;

    // Retrieve authority
    int endAuthority = leftUrl.indexOf('/');
    // No path, incomplete URL —> return image.jpg but should never happen
    if (endAuthority == -1) return null;
    leftUrl = leftUrl.substring(endAuthority);

    // The Piwigo server may not be in the root e.g. example.com/piwigo/…
    // So we remove the path to avoid a duplicate if necessary
    String? loginUrl = appPreferences.getString(Preferences.serverUrlKey);
    loginUrl = removeUrlProtocol(loginUrl);
    if (loginUrl != null &&
        loginUrl.isNotEmpty &&
        leftUrl.startsWith(loginUrl)) {
      leftUrl = leftUrl.substring(loginUrl.length);
    }

    // Retrieve path
    int endQuery = leftUrl.indexOf('?');
    if (endQuery != -1) {
      String query = leftUrl.substring(0, endQuery);
      query.replaceAll('??', '?');
      String encodedQuery = Uri.encodeComponent(query);
      leftUrl.substring(0, query.length);
      String encodedPath = Uri.encodeComponent(leftUrl);
      serverUrl = Uri.tryParse("$loginUrl$encodedQuery$encodedPath");
    } else {
      // No query -> remaining string is a path
      String encodedPath = Uri.encodeComponent(leftUrl);
      serverUrl = Uri.tryParse("$loginUrl$encodedPath");
    }

    // Last check
    if (serverUrl == null) {
      // Could not apply percent encoding —> return nil
      return null;
    }
  }

  // Servers may return image URLs different from those used to login (e.g. wrong server settings)
  // We only keep the path+query because we only accept to download images from the same server.
  String cleanPath = serverUrl.path;
  // todo : parameterString
  String query = serverUrl.query;
  if (query.isNotEmpty) {
    cleanPath.joinChar("?$query");
  }
  String fragment = serverUrl.fragment;
  if (fragment.isNotEmpty) {
    cleanPath.joinChar("#$fragment");
  }

  // The Piwigo server may not be in the root e.g. example.com/piwigo/…
  // and images may not be in the same path
  String? loginPath = appPreferences.getString(Preferences.serverUrlKey);
  loginPath = removeUrlProtocol(loginPath);
  if (loginPath != null && loginPath.isNotEmpty) {
    if (cleanPath.startsWith(loginPath)) {
      cleanPath = cleanPath.substring(loginPath.length);
    } else if (cleanPath.endsWith(loginPath)) {
      cleanPath = cleanPath.substring(0, cleanPath.length - loginPath.length);
    }
  }

  // Remove the .php?, i? prefixes if any
  String prefix = '';
  int pos = cleanPath.indexOf('?');
  if (pos != -1) {
    prefix = cleanPath.substring(0, pos);
  }

  // Path may not be encoded
  String decodedPath = Uri.decodeComponent(cleanPath);
  if (cleanPath == decodedPath) {
    String test = Uri.encodeComponent(cleanPath);
    cleanPath = test;
  }

  // Compile final URL using the one provided at login
  String encodedImageUrl = "${serverUrl.scheme}://$loginPath$prefix$cleanPath";
  if (kDebugMode) {
    if (encodedImageUrl != originalUrl) {
      print("=> originalURL:$originalUrl");
      print("   encodedURL:$encodedImageUrl");
      print(
          "   path=${serverUrl.path}, parameterString=${serverUrl.data}, query:${serverUrl.query}, fragment:${serverUrl.fragment}");
    }
  }

  return encodedImageUrl;
}
