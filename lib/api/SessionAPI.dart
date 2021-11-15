import 'dart:convert';

import 'package:dio/dio.dart';

import 'API.dart';

Future<String> loginUser(String url, String username, String password) async {
  Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.session.login'
  };
  Map<String, String> fields = {
    'username': username,
    'password': password,
  };

  API.dio.options.baseUrl = url;

  try {
    Response response = await API.dio.post('ws.php',
      data: FormData.fromMap(fields),
      options: Options(contentType: Headers.formUrlEncodedContentType),
      queryParameters: queries,
    );

    API.cookieJar.loadForRequest(Uri.parse(url));
    if(response.statusCode == 200) {
      if(json.decode(response.data)['stat'] == 'ok') {
        var status = await sessionStatus();
        print(status);
        if(status["stat"] == "ok") {
          print("$url, $username");
          savePreferences(status["result"], url: url, username: username, password: password, isLogged: true, isGuest: false);
          return null;
        }
        return 'Invalid url';
      }
      return 'Invalid username / password';
    }

  } catch(e) {
    return 'Dio: Invalid url. Exception: ' + e.toString();
  }
  return 'Something happened';
}
Future<String> loginGuest(String url) async {

  API.dio.options.baseUrl = url;

  var status = await sessionStatus();

  if(status["stat"] == "ok") {
    savePreferences(status["result"], url: url, username: "", password: "", isLogged: true, isGuest: true);
    return null;
  }
  return 'Invalid url';
}

Future<Map<String, dynamic>> sessionStatus() async {
  Map<String, String> queries = {
    'format': 'json',
    'method': 'pwg.session.getStatus'
  };

  try {
    Response response = await API.dio.get('ws.php', queryParameters: queries);
    return json.decode(response.data);
  } catch (e) {
    print('Dio error $e');
    return {"stat": "KO"};
  }
}

void saveStatus(Map<String, dynamic> status) async {
  print(status);
  API.prefs.setString("account_username", status["username"]);
  API.prefs.setString('pwg_token', status['pwg_token']);
  API.prefs.setString("status", status["status"]);
  API.prefs.setString("version", status["version"]);
  API.prefs.setStringList("available_sizes", status["available_sizes"].cast<String>());
  if(API.prefs.getString("user_status") == "admin" || API.prefs.getString("user_status") == "webmaster") {
    API.prefs.setInt('upload_form_chunk_size', status['upload_form_chunk_size']);
    API.prefs.setString("file_types", status["upload_file_types"]);
  }
  if(API.prefs.getString('thumbnail_size') == null) API.prefs.setString('thumbnail_size', 'medium');
  if(API.prefs.getString('full_screen_image_size') == null) API.prefs.setString('full_screen_image_size', 'medium');
  if(API.prefs.getString('album_thumbnail_size') == null) API.prefs.setString('album_thumbnail_size', 'medium');
}

void savePreferences(Map<String, dynamic> status, {
  String url,
  String username,
  String password,
  bool isLogged,
  bool isGuest
}) async {
  API.prefs.setString('username', url);
  API.prefs.setString('username', username);
  API.prefs.setString('password', password);
  API.prefs.setBool("is_logged", isLogged);
  API.prefs.setBool("is_guest", isGuest);
  API.prefs.setString("user_status", status["status"]);
  API.prefs.setString("base_url", url);

  API.prefs.setString("default_album", "Root Album");
  if(API.prefs.getInt("default_thumbnails_size") == null) API.prefs.setInt("default_thumbnails_size", 0);
  if(API.prefs.getInt("sort") == null) API.prefs.setInt("sort", 0);
  if(API.prefs.getInt("recent_albums") == null) API.prefs.setInt("recent_albums", 5);
  if(API.prefs.getDouble("portrait_image_count") == null) API.prefs.setDouble("portrait_image_count", 4);
  if(API.prefs.getDouble("landscape_image_count") == null) API.prefs.setDouble("landscape_image_count", 6);
  if(API.prefs.getBool("show_thumbnail_title") == null) API.prefs.setBool("show_thumbnail_title", false);
  saveStatus(status);
}