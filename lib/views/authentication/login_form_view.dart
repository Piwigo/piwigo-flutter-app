import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/api/authentication.dart';
import 'package:piwigo_ng/app.dart';
import 'package:piwigo_ng/components/buttons/animated_piwigo_button.dart';
import 'package:piwigo_ng/components/snackbars.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/fields/app_field.dart';
import '../album/root_album_view_page.dart';

class LoginFormView extends StatefulWidget {
  const LoginFormView({
    Key? key,
    this.autoLogin = false,
  }) : super(key: key);

  final bool autoLogin;

  @override
  State<LoginFormView> createState() => _LoginFormViewState();
}

class _LoginFormViewState extends State<LoginFormView> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  String _url = '';
  String _username = '';
  String _password = '';

  bool _isSecured = true;
  bool _showPassword = false;
  bool _idError = false;
  bool _urlError = false;

  @override
  initState() {
    super.initState();
    _initFields();
  }

  Future<void> _initFields() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    String? url = await storage.read(key: 'SERVER_URL');
    if (url == null || url.isEmpty) return;
    List<String> urlFields = url.split('://');
    _isSecured = urlFields.first == 'https';
    _url = urlFields.last.substring(0, urlFields.last.lastIndexOf('/'));
    _username = await storage.read(key: 'SERVER_USERNAME') ?? '';
    _password = await storage.read(key: 'SERVER_PASSWORD') ?? '';
    _urlController.text = _url;
    _usernameController.text = _username;
    _passwordController.text = _password;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        bool isError = !_urlValidator(url);
        if (_urlError != isError) {
          setState(() {
            _urlError = isError;
          });
        }
      }
      if (widget.autoLogin) _onLogin();
    });
  }

  bool _urlValidator(String? value) {
    RegExp urlCheck = RegExp(
      r"[(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)",
    );
    if (value == null || value.isEmpty || !urlCheck.hasMatch(value)) {
      return false;
    }
    return true;
  }

  void _onLoginError(ApiResult result) {
    _btnController.error();
    setState(() {
      switch (result.error) {
        case ApiErrors.wrongLoginId:
          ScaffoldMessenger.of(context).showSnackBar(
            errorSnackBar(
              message: appStrings.loginError_message,
              icon: Icons.text_fields,
            ),
          );
          _idError = true;
          break;
        case ApiErrors.wrongServerUrl:
          ScaffoldMessenger.of(context).showSnackBar(
            errorSnackBar(
              message: appStrings.serverURLerror_title,
              icon: Icons.public_off,
            ),
          );
          _urlError = true;
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            errorSnackBar(
              message: appStrings.serverUnknownError_message,
            ),
          );
      }
    });
  }

  Future<void> _onLoginSuccess(ApiResult result) async {
    _btnController.success();
    await Future.delayed(const Duration(milliseconds: 300));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    debugPrint("is admin: ${prefs.getBool('IS_USER_ADMIN')}");
    Navigator.of(context).pushReplacementNamed(
      RootAlbumViewPage.routeName,
      arguments: {'isAdmin': prefs.getBool('IS_USER_ADMIN')},
    );
  }

  void _onLogin() async {
    if (_urlError) return;
    App.scaffoldMessengerKey.currentState?.clearSnackBars();
    _btnController.start();
    try {
      var result = await loginUser(
        '${_isSecured ? 'https' : 'http'}://$_url/',
        username: _username,
        password: _password,
      );
      if (result.data == false || result.error != null) {
        _onLoginError(result);
      } else {
        await _onLoginSuccess(result);
      }
    } on Error catch (e) {
      debugPrint(e.toString());
      _btnController.error();
      ScaffoldMessenger.of(context).showSnackBar(
        errorSnackBar(
          message: appStrings.serverUnknownError_message,
        ),
      );
    }
    await Future.delayed(const Duration(seconds: 1));
    _btnController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppField(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            controller: _urlController,
            focusNode: _urlFocusNode,
            onChanged: (value) {
              bool isError = !_urlValidator(value);
              if (_urlError != isError) {
                setState(() {
                  _urlError = isError;
                });
              }
              setState(() {
                _url = value;
              });
            },
            textInputAction: TextInputAction.next,
            icon: const Icon(Icons.public),
            hint: 'example.piwigo.com',
            error: _urlError,
            prefix: _securedPrefix,
          ),
          AppField(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            controller: _usernameController,
            focusNode: _usernameFocusNode,
            onChanged: (value) {
              if (_idError) {
                setState(() {
                  _idError = false;
                });
              }
              setState(() {
                _username = value;
              });
            },
            textInputAction: TextInputAction.next,
            hint: "username",
            error: _idError,
            enableClearAction: true,
            icon: const Icon(Icons.person),
          ),
          AppField(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            onFieldSubmitted: (String value) {
              FocusScope.of(context).unfocus();
              _onLogin();
            },
            onChanged: (value) {
              if (_idError) {
                setState(() {
                  _idError = false;
                });
              }
              setState(() {
                _password = value;
              });
            },
            textInputAction: TextInputAction.done,
            obscureText: !_showPassword,
            hint: "password",
            error: _idError,
            enableClearAction: true,
            icon: GestureDetector(
              onTap: () => setState(() {
                _showPassword = !_showPassword;
              }),
              child: Icon(_showPassword ? Icons.lock_open : Icons.lock),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: AnimatedPiwigoButton(
              controller: _btnController,
              disabled: _urlError,
              color: Theme.of(context).primaryColor,
              onPressed: _onLogin,
              child: Text(
                appStrings.login,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _securedPrefix {
    return GestureDetector(
      onTap: () => setState(() {
        _isSecured = !_isSecured;
      }),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Text(
            '${_isSecured ? 'https' : 'http'}://',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Positioned(
            top: Theme.of(context).textTheme.bodyMedium?.fontSize,
            child: Text(
              !_isSecured ? 'https' : 'http',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
