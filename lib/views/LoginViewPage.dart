import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/SessionAPI.dart';
import 'package:flutter/material.dart';


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
  bool _obscurePassword;
  FocusNode urlFieldFocus = FocusNode();
  TextEditingController urlController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void createDio() async {
    API.dio = Dio();
    API.cookieJar = CookieJar();
    API.dio.interceptors.add(CookieManager(API.cookieJar));
    if(API.prefs.getBool("is_logged") != null && API.prefs.getBool("is_logged")) {
      API.dio.options.baseUrl = API.prefs.getString("base_url");
      String message;
      if(API.prefs.getBool("is_guest") != null && !API.prefs.getBool("is_guest")) {
        message = await loginUser(API.prefs.getString("base_url"), API.prefs.getString("username"), API.prefs.getString("password"));
        if(message == null) {
          Navigator.of(context).pushReplacementNamed("/root",
            arguments: true,
          );
          return;
        }
      } else {
        message = await loginGuest(API.prefs.getString("base_url"));
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
    if(API.prefs.getString("base_url") != null) {
      String url = API.prefs.getString("base_url");
      url = url.split('//')[1];
      url = url.substring(0, url.lastIndexOf('/'));
      setState(() {
        urlController.text = url;
        usernameController.text = API.prefs.getString("username") == null? '' : API.prefs.getString("username");
        passwordController.text = API.prefs.getString("password") == null? '' : API.prefs.getString("password");
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
    _obscurePassword = true;
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
        extendBody: true,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: constraints.copyWith(
                      minHeight: constraints.maxHeight,
                      maxHeight: double.infinity,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          children: <Widget>[
                            Column(
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
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
                                            decoration: InputDecoration(
                                              icon: Icon(Icons.person, color: _theme.disabledColor),
                                              border: InputBorder.none,
                                              hintText: 'username (optional)',
                                              hintStyle: TextStyle(fontStyle: FontStyle.italic, color: _theme.disabledColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          usernameController.text = '';
                                        });
                                      },
                                      child: Icon(Icons.highlight_remove),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
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
                                            obscureText: _obscurePassword,
                                            decoration: InputDecoration(
                                              icon: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _obscurePassword = !_obscurePassword;
                                                  });
                                                },
                                                child: _obscurePassword ?
                                                  Icon(Icons.lock, color: _theme.disabledColor) :
                                                  Icon(Icons.lock_open, color: _theme.disabledColor),
                                              ),
                                              border: InputBorder.none,
                                              hintText: 'password (optional)',
                                              hintStyle: TextStyle(fontStyle: FontStyle.italic, color: _theme.disabledColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          passwordController.text = '';
                                        });
                                      },
                                      child: Icon(Icons.highlight_remove),
                                    ),
                                  ],
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
                                    child: _isLoading? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Text('Log in', style: TextStyle(fontSize: 16, color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(top: 20),
                                alignment: Alignment.bottomCenter,
                                child: Text('v0.0.1-beta', style: TextStyle(fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
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


