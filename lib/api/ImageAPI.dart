import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:piwigo_ng/views/components/snackbars.dart';

import 'API.dart';

Future<Map<String,dynamic>> fetchImages(String albumID, int page) async {
  Map<String, String> queries = {
    "format":"json",
    "method": "pwg.categories.getImages",
    "cat_id": albumID,
    "per_page": "100",
    "page": page.toString(),
  };

  try {
    Response response = await API.dio.get('ws.php', queryParameters: queries);

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      return {
        'stat': 'fail',
        'result': response.statusMessage
      };
    }
  } catch(e) {
    var error = e as DioError;
    return {
      'stat': 'fail',
      'result': error.message
    };
  }
}

Future<dynamic> getImageInfo(int imageId) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.images.getInfo",
  };
  FormData formData =  FormData.fromMap({
    "image_id": imageId
  });
  try {
    Response response = await API.dio.post('ws.php',
        data: formData,
        queryParameters: queries
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      return {
        'stat': 'fail',
        'result': response.statusMessage
      };
    }
  } catch (e) {
    var error = e as DioError;
    return {
      'stat': 'fail',
      'result': error.message
    };
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
    return ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_PICTURES);
  }
  return (await getApplicationDocumentsDirectory()).path;
}
Future<void> _showNotification(Map<String, dynamic> downloadStatus) async {
  final android = AndroidNotificationDetails(
        'channel id',
        'channel name',
        channelDescription: 'channel description',
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

Future<void> downloadSingleImage(dynamic image) async {
  final isPermissionStatusGranted = await _requestPermissions();
  final dirPath = await _getDownloadPath();

  Map<String, dynamic> result = {
    'isSuccess': true,
    'filePath': null,
    'error': null,
  };

  if (isPermissionStatusGranted) {
    await downloadImage(
      dirPath,
      image['element_url'],
      image['file'],
    );
    await _showNotification(result);
  } else {
    print('No storage Permission');
  }
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
      );
    });
    await _showNotification(result);
  } else {
    print('No storage Permission');
  }
}
Future<dynamic> downloadImage(String dirPath, String url, String file) async {

  var localPath = path.join(dirPath, file);
  try {
    Response response = await API.dio.download(
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

Future<int> deleteImages(BuildContext context, List<int> imageIdList) async {
  int nbSuccess = 0;
  for(int id in imageIdList) {
    var response = await deleteImage(id);
    if(response['stat'] == 'fail') {
      print(response);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        errorSnackBar(context, '${response['result']}'),
      );
      break;
    } else {
      nbSuccess++;
    }
  }
  return nbSuccess;
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
    Response response = await API.dio.post('ws.php',
        data: formData,
        queryParameters: queries
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      return {
        'stat': 'fail',
        'result': response.statusMessage
      };
    }
  } catch (e) {
    var error = e as DioError;
    return {
      'stat': 'fail',
      'result': error.message
    };
  }
}

Future<int> removeImages(BuildContext context, List<int> imageIdList, String catId) async {
  int nbSuccess = 0;
  for(int id in imageIdList) {
    var response = await removeImage(id, catId);
    if(response['stat'] == 'fail') {
      print(response);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        errorSnackBar(context, '${response['result']}'),
      );
      break;
    } else {
      nbSuccess++;
    }
  }
  return nbSuccess;
}
Future<dynamic> removeImage(int imageId, String catId) async {
  var imageInfo = await getImageInfo(imageId);
  if(imageInfo['stat'] == 'fail') return imageInfo;

  List<String> categories = imageInfo['result']['categories'].map<String>(
      (cat) => cat['id'].toString()
  ).toList();
  categories.removeWhere((cat) => cat == catId);

  if(categories.isEmpty) {
    return await deleteImage(imageId);
  }

  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.images.setInfo",
  };
  FormData formData =  FormData.fromMap({
    "image_id": imageId,
    "categories": categories,
    "multiple_value_mode": "replace"
  });

  try {
    Response response = await API.dio.post('ws.php',
        data: formData,
        queryParameters: queries
    );

    print(response.data);

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      return {
        'stat': 'fail',
        'result': response.statusMessage
      };
    }
  } catch (e) {
    var error = e as DioError;
    return {
      'stat': 'fail',
      'result': error.message
    };
  }
}

Future<int> moveImages(BuildContext context, List<dynamic> images, int category) async {
  int nbMoved = 0;
  for(var image in images) {
    var response = await moveImage(image['id'], [category]);
    if(response['stat'] == 'fail') {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
          errorSnackBar(context, '${response['result']}')
      );
      break;
    } else {
      nbMoved++;
    }
  }
  return nbMoved;
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
      return {
        'stat': 'fail',
        'result': response.statusMessage
      };
    }
  } catch (e) {
    var error = e as DioError;
    return {
      'stat': 'fail',
      'result': error.message
    };
  }
}

Future<int> assignImages(BuildContext context, List<dynamic> images, int category) async {
  int nbAssigned = 0;
  for(var image in images) {
    List<int> categories = image['categories'].map<int>((cat) {
      return cat['id'] as int;
    }).toList();
    categories.add(category);
    var response = await assignImage(image['id'], categories);
    if(response['stat'] == 'fail') {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
          errorSnackBar(context, '${response['result']}')
      );
      break;
    } else {
      nbAssigned++;
    }
  }
  return nbAssigned;
}
Future<dynamic> assignImage(int imageId, List<int> categories) async {
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
    } else {
      return {
        'stat': 'fail',
        'result': response.statusMessage
      };
    }
  } catch (e) {
    var error = e as DioError;
    return {
      'stat': 'fail',
      'result': error.message
    };
  }
}

Future<int> editImages(BuildContext context, List<Map<String, dynamic>> images, List<int> tags, int level) async {
  int nbEdited = 0;
  for(var image in images) {
    var response = await editImage(image['id'], image['name'], image['desc'], tags, level);
    if(response['stat'] != 'fail') {
      nbEdited++;
    }
  }
  return nbEdited;
}
Future<dynamic> editImage(int imageId, String name, String desc, List<int> tags, int level) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.images.setInfo",
  };

  Map<String,dynamic> form = {
    "image_id": imageId,
    "single_value_mode": "replace",
    "multiple_value_mode": "append"
  };
  if(name != "" && name != null) form["name"] = name;
  if(desc != "" && desc != null) form["comment"] = desc;
  if(tags.isNotEmpty) form["tag_ids"] = tags;
  if(level != -1) form["level"] = level;

  FormData formData = FormData.fromMap(form);

  try {
    Response response = await API.dio.post('ws.php',
        data: formData,
        queryParameters: queries
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      return {
        'stat': 'fail',
        'result': response.statusMessage
      };
    }
  } catch (e) {
    var error = e as DioError;
    return {
      'stat': 'fail',
      'result': error.message
    };
  }
}

Future<dynamic> renameImage(int imageId, String name) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.images.setInfo",
  };

  Map<String,dynamic> form = {
    "image_id": imageId,
    "name": name,
    "single_value_mode": "replace"
  };

  FormData formData = FormData.fromMap(form);

  try {
    Response response = await API.dio.post('ws.php',
        data: formData,
        queryParameters: queries
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      return {
        'stat': 'fail',
        'result': response.statusMessage
      };
    }
  } catch (e) {
    var error = e as DioError;
    return {
      'stat': 'fail',
      'result': error.message
    };
  }
}