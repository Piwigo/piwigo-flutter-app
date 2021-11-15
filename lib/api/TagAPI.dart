import 'dart:convert';

import 'package:dio/dio.dart';
import 'API.dart';

Future<Map<String,dynamic>> getAdminTags() async {
  Map<String, String> queries = {
    "format":"json",
    "method": "pwg.tags.getAdminList",
  };

  Response response = await API().dio.get('ws.php', queryParameters: queries);

  try {
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

Future<dynamic> createTag(String tagName) async {
  Map<String, String> queries = {
    "format":"json",
    "method": "pwg.tags.add",
    "name": tagName,
  };

  try {
    Response response = await API().dio.get('ws.php', queryParameters: queries);

    if (response.statusCode == 200) {
      return json.decode(response.data)["result"];
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