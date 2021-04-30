import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          savePreferences(status["result"], url: url, username: username, password: password, isLogged: true, isGuest: false);
          return null;
        }
        return 'Invalid url';
      }
      return 'Invalid username / password';
    }

  } catch(e) {
    return 'Dio: Invalid url';
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
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print(status);
  prefs.setString("account_username", status["username"]);
  prefs.setString('pwg_token', status['pwg_token']);
  prefs.setString("status", status["status"]);
  prefs.setString("version", status["version"]);
  prefs.setStringList("available_sizes", status["available_sizes"].cast<String>());
  if(prefs.getBool("is_logged") && !prefs.getBool("is_guest")) {
    prefs.setInt('upload_form_chunk_size', status['upload_form_chunk_size']);
    prefs.setString("file_types", status["upload_file_types"]);
  }
}

void savePreferences(Map<String, dynamic> status, {
  String url,
  String username,
  String password,
  bool isLogged,
  bool isGuest
}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setString('username', url);
  prefs.setString('username', username);
  prefs.setString('password', password);
  prefs.setBool("is_logged", isLogged);
  prefs.setBool("is_guest", isGuest);
  prefs.setString("base_url", url);

  prefs.setString("default_album", "Root Album");
  if(prefs.getInt("default_miniatures_size") == null) {
    prefs.setInt("default_miniatures_size", 0);
  }
  if(prefs.getInt("sort") == null) {
    prefs.setInt("sort", 0);
  }
  if(prefs.getInt("recent_albums") == null) {
    prefs.setInt("recent_albums", 5);
  }
  saveStatus(status);
}