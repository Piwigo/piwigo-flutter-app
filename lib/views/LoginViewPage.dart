import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/SessionAPI.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/views/PrivacyPolicyViewPage.dart';
import 'package:piwigo_ng/views/components/buttons.dart';

import 'components/dialogs/error_dialog.dart';


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
    API().dio = Dio();
    API.cookieJar = CookieJar();
    API().dio.interceptors.add(CookieManager(API.cookieJar));
    if(API.prefs.getBool("is_logged") != null && API.prefs.getBool("is_logged")) {
      setState(() {
        _isLoading = true;
      });
      API().dio.options.baseUrl = API.prefs.getString("base_url");
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
      setState(() {
        _isLoading = false;
      });
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            errorTitle: appStrings(context).loginError_title,
            errorMessage: message
          );
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
    WidgetsBinding.instance.addPostFrameCallback((_) => createDio());
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.initState();
  }

  @override
  void dispose() {
    urlController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void onConnection() async {
    if(!_validUrl) return;
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
          return ErrorDialog(
              errorTitle: appStrings(context).loginError_title,
              errorMessage: errorMessage
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
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
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      child: Column(
                        children: <Widget>[
                          Expanded(
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
                                      style: _theme.inputDecorationTheme.labelStyle,
                                      focusNode: urlFieldFocus,
                                      decoration: InputDecoration(
                                        icon: _validUrl?
                                        Icon(Icons.public, color: _theme.inputDecorationTheme.hintStyle.color) :
                                        Icon(Icons.error_outline, color: _theme.errorColor),
                                        border: InputBorder.none,
                                        hintText: appStrings(context).login_serverPlaceholder,
                                        hintStyle: _theme.inputDecorationTheme.hintStyle,
                                        prefix: urlFieldFocus.hasFocus? InkWell(
                                          onTap: () {
                                            setState(() {
                                              _httpProtocol = !_httpProtocol;
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Text(protocol(_httpProtocol), style: _theme.inputDecorationTheme.labelStyle),
                                              Text(protocol(!_httpProtocol), style: TextStyle(fontSize: 9, color: _theme.inputDecorationTheme.labelStyle.color)),
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
                                            style: _theme.inputDecorationTheme.labelStyle,
                                            maxLines: 1,
                                            decoration: InputDecoration(
                                              icon: Icon(Icons.person, color: _theme.inputDecorationTheme.hintStyle.color),
                                              border: InputBorder.none,
                                              hintText: appStrings(context).login_userPlaceholder,
                                              hintStyle: _theme.inputDecorationTheme.hintStyle,
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
                                      child: Transform.rotate(
                                        angle: 45*pi/180,
                                        child: Icon(Icons.add_circle, size: 30),
                                      ),
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
                                            style: _theme.inputDecorationTheme.labelStyle,
                                            obscureText: _obscurePassword,
                                            decoration: InputDecoration(
                                              icon: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _obscurePassword = !_obscurePassword;
                                                  });
                                                },
                                                child: _obscurePassword ?
                                                Icon(Icons.lock, color: _theme.inputDecorationTheme.hintStyle.color) :
                                                Icon(Icons.lock_open, color: _theme.inputDecorationTheme.hintStyle.color),
                                              ),
                                              border: InputBorder.none,
                                              hintText: appStrings(context).login_passwordPlaceholder,
                                              hintStyle: _theme.inputDecorationTheme.hintStyle,
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
                                      child: Transform.rotate(
                                        angle: 45*pi/180,
                                        child: Icon(Icons.add_circle, size: 30),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 60,
                                  padding: EdgeInsets.all(5),
                                  child: DialogButton(
                                    style: _validUrl ? dialogButtonStyle(context) : dialogButtonStyleDisabled(context),
                                    child: _isLoading?
                                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) :
                                    Text(appStrings(context).login, style: TextStyle(fontSize: 16, color: Colors.white)),
                                    onPressed: onConnection,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            alignment: Alignment.bottomCenter,
                            child: RichText(
                              text: TextSpan(
                                  text: appStrings(context).settings_privacy,
                                  style: _theme.textTheme.headline6,
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => PrivacyPolicyViewPage())
                                      );
                                    }
                              ),
                            ),
                          ),
                          FutureBuilder<PackageInfo>(
                            future: PackageInfo.fromPlatform(),
                            builder: (context, snapshot) {
                              if(snapshot.hasData) {
                                return Text(snapshot.data.version,
                                  style: _theme.textTheme.headline5,
                                );
                              }
                              return SizedBox();
                            },
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
  }
}


