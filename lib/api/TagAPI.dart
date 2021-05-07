

import 'dart:convert';

import 'package:dio/dio.dart';

import 'API.dart';

Future<List<dynamic>> getAdminTags() async {
  Map<String, String> queries = {
    "format":"json",
    "method": "pwg.tags.getAdminList",
  };

  Response response = await API.dio.get('ws.php', queryParameters: queries);

  if (response.statusCode == 200) {
    return json.decode(response.data)["result"]['tags'];
  } else {
    throw Exception("bad request: "+response.statusCode.toString());
  }
}

Future<dynamic> createTag(String tagName) async {
  Map<String, String> queries = {
    "format":"json",
    "method": "pwg.tags.add",
    "name": tagName,
  };

  Response response = await API.dio.get('ws.php', queryParameters: queries);

  if (response.statusCode == 200) {
    return json.decode(response.data)["result"];
  } else {
    throw Exception("bad request: "+response.statusCode.toString());
  }
}