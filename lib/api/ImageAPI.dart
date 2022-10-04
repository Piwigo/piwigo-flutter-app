import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:piwigo_ng/views/components/snackbars.dart';
import 'package:share_plus/share_plus.dart';

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
    Response response = await API().dio.get('ws.php', queryParameters: queries);

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
    Response response = await API().dio.post('ws.php',
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
  if (permission != PermissionStatus.granted) {
    await Permission.storage.request();
    permission = await Permission.storage.status;
  }

  return permission == PermissionStatus.granted;
}
Future<String> pickDirectoryPath() async {
  return await FilePicker.platform.getDirectoryPath();
}
Future<void> _showNotification({bool success = true, String payload}) async {
  if(!(API.prefs.getBool('download_notification') ?? true)) return;
  final android = AndroidNotificationDetails(
    'id',
    'Piwigo NG Download',
    channelDescription: 'piwigo_ng',
    priority: Priority.defaultPriority,
    importance: Importance.defaultImportance,
  );
  final platform = NotificationDetails(android: android);

  await API.localNotification.show(
    0,
    success ? 'Success' : 'Failure',
    success ? 'All files has been downloaded successfully!' : 'There was an error while downloading the file.',
    platform,
    payload: payload,
  );
}

Future<void> share(List<dynamic> images) async {
  List<String> filesPath = await downloadImages(images,
    showNotification: false,
    cached: true,
  );
  print(filesPath);
  if(filesPath == null) return;
  if(filesPath.isNotEmpty) {
    Share.shareFiles(filesPath);
  }
}

Future<List<String>> downloadImages(List<dynamic> images, {bool showNotification = true, bool cached = false}) async {
  final isPermissionStatusGranted = await _requestPermissions();
  if (!isPermissionStatusGranted) return null;

  String dirPath = (await getTemporaryDirectory()).path;
  if(!cached) {
    if(API.prefs.getString('download_destination') != null) {
      dirPath = API.prefs.getString('download_destination');
    } else {
      dirPath = await pickDirectoryPath();
    }
  }
  if(dirPath == null) return null;

  final List<String> filesPath = [];

  await Future.forEach(images, (image) async {
    String filePath = await downloadImage(
      dirPath,
      image['element_url'],
      image['file'],
    );
    if(filePath != null) {
      filesPath.add(filePath);
    }
  });

  if(showNotification) {
    if(filesPath.isNotEmpty) {
      await _showNotification(
        success: true,
        payload: filesPath.length == 1 ? filesPath.first : '$dirPath\\',
      );
    } else {
      await _showNotification(success: false);
    }
  }
  return filesPath;
}
Future<String> downloadImage(String dirPath, String url, String file) async {
  String localPath = path.join(dirPath, file);
  try {
    Response response = await API().dio.download(
      url,
      localPath,
    );
    return localPath;
  } catch (e) {
    print("Download error: $e");
    return null;
  }
}

Future<int> deleteImages(BuildContext context, List<int> imageIdList) async {
  int nbSuccess = 0;
  for(int id in imageIdList) {
    var response = await deleteImage(id);
    if(response['stat'] == 'fail') {
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
    Response response = await API().dio.post('ws.php',
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
    Response response = await API().dio.post('ws.php',
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
    Response response = await API().dio.post(
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
    Response response = await API().dio.post(
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
    Response response = await API().dio.post('ws.php',
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
    Response response = await API().dio.post('ws.php',
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

Future<dynamic> uploadCompleted(List<int> imageId, int categoryId) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.images.uploadCompleted",
  };
  FormData formData =  FormData.fromMap({
    "image_id": imageId,
    "pwg_token": API.prefs.getString("pwg_token"),
    "category_id": categoryId,
  });
  try {
    Response response = await API().dio.post('ws.php',
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
Future<dynamic> communityUploadCompleted(List<int> imageId, int categoryId) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "community.images.uploadCompleted",
  };
  FormData formData =  FormData.fromMap({
    "image_id": imageId,
    "pwg_token": API.prefs.getString("pwg_token"),
    "category_id": categoryId,
  });
  try {
    Response response = await API().dio.post('ws.php',
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