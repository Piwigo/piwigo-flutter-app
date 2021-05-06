import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

import 'API.dart';

Future<List<dynamic>> fetchImages(String albumID, int page) async {
  Map<String, String> queries = {
    "format":"json",
    "method": "pwg.categories.getImages",
    "cat_id": albumID,
    "per_page": "100",
    "page": page.toString(),
  };

  Response response = await API.dio.get('ws.php', queryParameters: queries);

  if (response.statusCode == 200) {
    // TODO : Use model class instead of a map
    /*
      json.decode(response.data)["result"].map<ImageModel>((image) {
        Map<String, DerivativeModel> derivs = Map();
        image['derivatives'].forEach((deriv) {
          derivs.putIfAbsent(deriv.key, () =>
              DerivativeModel(deriv['url'], deriv['width'], deriv['height']));
        });
        return ImageModel(image['id'], image['file'], image['name'],
            image['comment'], image['element_url'], derivs,
            width: image['width'], height: image['height'],
            availableDate: image['date_available'], creationDate: image['date_creation'],
            hit: image['hit'], pageUrl: image['page_url']);
      }).toList();
       */
    return json.decode(response.data)["result"]["images"];
  } else {
    throw Exception("bad request: "+response.statusCode.toString());
  }
}

Future<bool> _requestPermissions() async {
  var permission = await Permission.storage.status;
  print(permission.isGranted);
  if (permission != PermissionStatus.granted) {
    await Permission.storage.request();
    permission = await Permission.storage.status;
  }

  return permission == PermissionStatus.granted;
}
Future<String> _getDownloadPath() async {
  if (Platform.isAndroid) {
    return ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
  }
  return (await getApplicationDocumentsDirectory()).path;
}
Future<void> _showNotification(Map<String, dynamic> downloadStatus) async {
  final android = AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel description',
      priority: Priority.high,
      importance: Importance.max
  );
  final platform = NotificationDetails(android: android);
  final isSuccess = downloadStatus['isSuccess'];

  await API.localNotification.show(
    0,
    isSuccess ? 'Success' : 'Failure',
    isSuccess ? 'All files has been downloaded successfully!' : 'There was an error while downloading the file.',
    platform,
  );
}

Future<void> downloadImages(List<dynamic> images) async {
  final isPermissionStatusGranted = await _requestPermissions();
  final dirPath = await _getDownloadPath();

  Map<String, dynamic> result = {
    'isSuccess': true,
    'filePath': null,
    'error': null,
  };

  if (isPermissionStatusGranted) {
    await Future.forEach(images, (image) async {
      await downloadImage(
        dirPath,
        image['element_url'],
        image['file'],
        images.indexOf(image)
      );
    });
    await _showNotification(result);
  } else {
    print('No storage Permission');
  }
}
Future<dynamic> downloadImage(String dirPath, String url, String file, int index) async {

  var localPath = path.join(dirPath, file);
  try {
    await API.dio.download(
      url,
      localPath,
    );
    // result['isSuccess'] = response.statusCode == 200;
    // result['filePath'] = localPath;
  } catch (e) {
    print(e);
    // result['error'] = e.toString();
  } finally {

  }
}

Future<void> deleteImages(List<int> imageIdList) async {
  for(int id in imageIdList) {
    await deleteImage(id);
  }
}
Future<dynamic> deleteImage(int imageId) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.images.delete",
  };
  FormData formData =  FormData.fromMap({
    "image_id": imageId,
    "pwg_token": API.prefs.getString("pwg_token"),
  });
  try {
    Response response = await API.dio.post(
        'ws.php',
        data: formData,
        queryParameters: queries
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    }
  } catch (e) {
    print('Dio delete category error $e');
    return e;
  }
}

Future<dynamic> moveImages(List<dynamic> images, int category) async {
  for(var image in images) {
    await moveImage(image['id'], [category]);
  }
}
Future<dynamic> moveImage(int imageId, List<int> categories) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.images.setInfo",
  };

  FormData formData = FormData.fromMap({
    "image_id": imageId,
    "categories": categories,
    "multiple_value_mode": "replace",
  });

  try {
    Response response = await API.dio.post(
      'ws.php',
      data: formData,
      queryParameters: queries
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      print('Error ${response.statusCode}');
    }
  } catch (e) {
    print('Dio move category error $e');
    return e;
  }
}

Future<dynamic> copyImages(List<dynamic> images, int category) async {
  for(var image in images) {
    List<int> categories = image['categories'].map<int>((cat) {
      return cat['id'] as int;
    }).toList();
    categories.add(category);
    await copyImage(image['id'], categories);
  }
}
Future<dynamic> copyImage(int imageId, List<int> categories) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.images.setInfo",
  };

  FormData formData = FormData.fromMap({
    "image_id": imageId,
    "categories": categories,
    "multiple_value_mode": "append",
  });

  try {
    Response response = await API.dio.post(
        'ws.php',
        data: formData,
        queryParameters: queries
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    }
  } catch (e) {
    print('Dio move category error $e');
    return e;
  }
}

Future<dynamic> editImage(int imageId, String name, String desc) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.images.setInfo",
  };
  FormData formData = FormData.fromMap({
    "image_id": imageId,
    "name": name,
    "comment": desc,
    "single_value_mode": "replace",
  });
  try {
    Response response = await API.dio.post(
        'ws.php',
        data: formData,
        queryParameters: queries
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    }
  } catch (e) {
    print('Dio move category error $e');
    return e;
  }
}