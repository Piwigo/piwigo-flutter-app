import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:poc_piwigo/api/API.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'RootCategoryViewPage.dart';


class CategoryPageArguments {
  final bool isAdmin;

  CategoryPageArguments(this.isAdmin);
}

class LoginViewPage extends StatefulWidget {
  LoginViewPage({Key key}) : super(key: key);

  @override
  _LoginViewPageState createState() => _LoginViewPageState();
}

class _LoginViewPageState extends State<LoginViewPage> {
  bool isLoggedIn;
  bool _isLoading;
  bool _validUrl;
  bool _httpProtocol;
  FocusNode urlFieldFocus = FocusNode();
  TextEditingController urlController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void createDio() async {
    API.dio = Dio();
    API.cookieJar = CookieJar();
    API.dio.interceptors.add(CookieManager(API.cookieJar));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getBool("is_logged") != null && prefs.getBool("is_logged")) {
      API.dio.options.baseUrl = prefs.getString("base_url");
      if(prefs.getBool("is_guest") != null && !prefs.getBool("is_guest")) {
        loginUser(prefs.getString("base_url"), prefs.getString("username"), prefs.getString("password"));
      } else {
        Navigator.of(context).pushReplacementNamed("/root",
          arguments: false,
        );
      }
    }
  }
  void saveStatus(Map<String, dynamic> status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

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
  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString("base_url") != null) {
      String url = prefs.getString("base_url");
      url = url.split('//')[1];
      url = url.substring(0, url.lastIndexOf('/'));
      setState(() {
        urlController.text = url;
        usernameController.text = prefs.getString("username") == null? '' : prefs.getString("username");
        passwordController.text = prefs.getString("password") == null? '' : prefs.getString("password");
      });
    }
  }

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
          var status = await sessionStatus(url);
          if(status["stat"] == "ok") {
            savePreferences(status["result"], url: url, username: username, password: password, isLogged: true, isGuest: false);
            Navigator.of(context).pushReplacementNamed("/root",
                arguments: true,
            );
            return null;
          }
          return 'Invalid url';
        }
        print(response.data);
        return 'Invalid username / password';
      }

    } catch(e) {
      return 'Dio: Invalid url';
    }
    return 'Something happened';
  }
  Future<String> loginGuest(String url) async {

    API.dio.options.baseUrl = url;

    var status = await sessionStatus(url);

    if(status["stat"] == "ok") {
      savePreferences(status["result"], url: url, username: "", password: "", isLogged: true, isGuest: true);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushReplacementNamed("/root",
        arguments: false,
      );
      return null;
    }
    return 'Invalid url';
  }
  Future<Map<String, dynamic>> sessionStatus(String url) async {
    Map<String, String> queries = {
      'format': 'json',
      'method': 'pwg.session.getStatus'
    };

    try {
      Response response = await API.dio.get('ws.php', queryParameters: queries);
      print(response.data);
      return json.decode(response.data);
    } catch (e) {
      print(e);
      return {"stat": "KO"};
    }
  }

  bool validateUrl(String value) {
    if (value == null || value.isEmpty /*|| !Uri.parse(value).isAbsolute*/) return false;
    return true;
  }

  String protocol(bool http) {
    return http ? "http://" : "https://";
  }

  @override
  void initState() {
    super.initState();
    createDio();
    isLoggedIn = false;
    _isLoading = false;
    _validUrl = false;
    _httpProtocol = false;
    urlController.addListener(() {
      bool valid = validateUrl(urlController.text);
      if(valid != _validUrl) {
        setState(() {
          _validUrl = valid;
        });
      }
    });
    urlFieldFocus.addListener(() {
      setState(() {
        print("Has focus: ${urlFieldFocus.hasFocus}");
      });
    });
    getSharedPrefs();
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    if (!this.isLoggedIn) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            padding: EdgeInsets.all(30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Text("Piwigo", style: _theme.textTheme.headline3),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Text("- Android@piwigo.org -", style: _theme.textTheme.headline4),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),

                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: _validUrl? Border.all(width: 0, color: Colors.transparent) : Border.all(color: _theme.errorColor),
                          color: _theme.inputDecorationTheme.fillColor
                      ),

                      child: TextFormField(
                        controller: urlController,
                        style: TextStyle(fontSize: 14, color: Color(0xff5c5c5c)),
                        focusNode: urlFieldFocus,
                        decoration: InputDecoration(
                          icon: _validUrl? Icon(Icons.public, color: _theme.disabledColor) : Icon(Icons.error_outline, color: _theme.errorColor),
                          border: InputBorder.none,
                          hintText: 'example.com',
                          hintStyle: TextStyle(fontStyle: FontStyle.italic, color: _theme.disabledColor),
                          prefix: urlFieldFocus.hasFocus? InkWell(
                            onTap: () {
                              setState(() {
                                _httpProtocol = !_httpProtocol;
                              });
                            },
                            child: Column(
                              children: [
                                Text(protocol(_httpProtocol), style: TextStyle(fontSize: 14, color: Color(0xff5c5c5c))),
                                Text(protocol(!_httpProtocol), style: TextStyle(fontSize: 9, color: Color(0xff5c5c5c))),
                              ],
                            ),
                          ) : urlController.text == null || urlController.text == "" ?
                              Text("") : Text(protocol(_httpProtocol), style: TextStyle(fontSize: 14, color: Color(0xff5c5c5c))),
                          suffixText: '/',
                          suffixStyle: TextStyle(fontSize: 14, color: Color(0xff5c5c5c)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _theme.inputDecorationTheme.fillColor
                      ),
                      child: TextFormField(
                        controller: usernameController,
                        style: TextStyle(fontSize: 14, color: Color(0xff5c5c5c)),
                        maxLines: 1,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                          icon: Icon(Icons.person, color: _theme.disabledColor),
                          border: InputBorder.none,
                          hintText: 'username (optional)',
                          hintStyle: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: _theme.disabledColor),
                          suffix: InkWell(
                            onTap: () {
                              setState(() {
                                usernameController.text = '';
                              });
                            },
                            child: Icon(Icons.highlight_remove),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _theme.inputDecorationTheme.fillColor
                      ),
                      child: TextFormField(
                        controller: passwordController,
                        style: TextStyle(fontSize: 14, color: Color(0xff5c5c5c)),
                        obscureText: true,
                        decoration: InputDecoration(
                          icon: Icon(Icons.lock, color: _theme.disabledColor),
                          border: InputBorder.none,
                          hintText: 'password (optional)',
                          hintStyle: TextStyle(fontStyle: FontStyle.italic, color: _theme.disabledColor),
                          suffix: InkWell(
                            onTap: () {
                              setState(() {
                                passwordController.text = '';
                              });
                            },
                            child: Icon(Icons.highlight_remove),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 60,
                    padding: EdgeInsets.all(5),
                    child: TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(_validUrl ? _theme.accentColor : _theme.disabledColor),
                      ),
                      onPressed: !_validUrl ? null : () async {
                        setState(() {
                          _isLoading = true;
                        });

                        String completeUrl = '${protocol(_httpProtocol)}${urlController.text.replaceAll(RegExp(r"\s+"), "")}/';
                        String errorMessage;

                        if(usernameController.text == "" && passwordController.text == "") {
                          errorMessage = await loginGuest(completeUrl);
                          setState(() {
                            _isLoading = false;
                          });
                        } else {
                          errorMessage = await loginUser(completeUrl, usernameController.text, passwordController.text);
                          setState(() {
                            _isLoading = false;
                          });
                        }

                        if(errorMessage != null) {
                          print(errorMessage);

                          showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext context) {
                              return connectionErrorDialog(errorMessage);
                            }
                          );
                        }
                      },
                      child: _isLoading? CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)) : Text('Log in', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }

  AlertDialog connectionErrorDialog(String error) {
    return AlertDialog(
      title: Text('Connection failed'),
      content: Text('$error'),
      actions: [
        IconButton(
          color: Color(0xffff0e00),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close, color: Color(0xffffffff),)
        ),
      ],
    );
  }
}


