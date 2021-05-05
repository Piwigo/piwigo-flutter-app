import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/SessionAPI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';


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
      String message;
      if(prefs.getBool("is_guest") != null && !prefs.getBool("is_guest")) {
        message = await loginUser(prefs.getString("base_url"), prefs.getString("username"), prefs.getString("password"));
        if(message == null) {
          Navigator.of(context).pushReplacementNamed("/root",
            arguments: true,
          );
          return;
        }
      } else {
        message = await loginGuest(prefs.getString("base_url"));
        if(message == null) {
          Navigator.of(context).pushReplacementNamed("/root",
            arguments: false,
          );
          return;
        }
      }
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return connectionErrorDialog(message);
        }
      );
    }
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
                    padding: EdgeInsets.all(50),
                    child: Image.asset('assets/logo/piwigo_logo.png'),
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
                          if(errorMessage == null) {
                            Navigator.of(context).pushReplacementNamed("/root",
                              arguments: false,
                            );
                            return;
                          }
                        } else {
                          errorMessage = await loginUser(completeUrl, usernameController.text, passwordController.text);
                          setState(() {
                            _isLoading = false;
                          });
                          if(errorMessage == null) {
                            Navigator.of(context).pushReplacementNamed("/root",
                              arguments: true,
                            );
                            return;
                          }
                        }

                        showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (BuildContext context) {
                            return connectionErrorDialog(errorMessage);
                          }
                        );
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


