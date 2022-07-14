import 'dart:convert';

import 'package:dio/dio.dart';
import 'API.dart';

Future<Map<String,dynamic>> searchAlbums(String searchQuery) async {

  Map<String, String> query = {
    "format": "json",
    "method": "pwg.images.search",
    "query": searchQuery,
  };

  try {
    Response response = await API().dio.get('ws.php', queryParameters: query);

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      return {
        'stat': 'fail',
        'result': response.statusMessage
      };
    }
  } catch(e) {
    return {
      'stat': 'fail',
      'result': e.toString(),
    };
  }
}