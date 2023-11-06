
Future<Map<String,dynamic>> getTags() async {
  Map<String, String> queries = {
    "format":"json",
    "method": "pwg.tags.getList",
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

Future<dynamic> editTag(int tagId, String tagName) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.tags.rename",
  };
  FormData formData = FormData.fromMap({
    "tag_id": tagId,
    "new_name": tagName,
    "pwg_token": API.prefs.getString("pwg_token"),
  });
  try {
    Response response = await API().dio.post(
      'ws.php',
      data: formData,
      queryParameters: queries,
    );
    if (response.statusCode == 200) {
      return json.decode(response.data);
    }
  } catch (e) {
    var error = e as DioError;
    return {
      'stat': 'fail',
      'result': error.message
    };
  }
}