import 'dart:convert';

import 'package:dio/dio.dart';
import 'API.dart';

Future<Map<String,dynamic>> fetchAlbums(String albumID) async {

  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.categories.getList",
    "cat_id": albumID,
    "thumbnail_size": API.prefs.getString('thumbnail_size'),
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
      'result': error.message,
    };
  }
}
Future<Map<String,dynamic>> getAlbumList() async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.categories.getAdminList",
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

Future<dynamic> addCategory(String catName, String catDesc, String parent) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.categories.add",
    "name": catName,
    "comment": catDesc,
    "parent": parent
  };
  try {
    Response response = await API().dio.post('ws.php', queryParameters: queries);

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
Future<dynamic> deleteCategory(String catId, {String deletionMode = "delete_orphans"}) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.categories.delete",
  };
  FormData formData =  FormData.fromMap({
    "category_id": catId,
    "pwg_token": API.prefs.getString("pwg_token"),
    'photo_deletion_mode': deletionMode,
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
  } catch(e) {
    var error = e as DioError;
    return {
      'stat': 'fail',
      'result': error.message
    };
  }
}
Future<dynamic> moveCategory(int catId, String parentCatId) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.categories.move",
  };
  FormData formData = FormData.fromMap({
    "category_id": catId,
    "parent": parentCatId,
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
  } catch(e) {
    var error = e as DioError;
    return {
      'stat': 'fail',
      'result': error.message
    };
  }
}
Future<dynamic> editCategory(int catId, String catName, String catDesc) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.categories.setInfo",
  };
  FormData formData = FormData.fromMap({
    "category_id": catId,
    "name": catName,
    "comment": catDesc,
  });
  try {
    Response response = await API().dio.post(
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