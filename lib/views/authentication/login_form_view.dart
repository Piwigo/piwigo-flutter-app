import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/api/authentication.dart';
import 'package:piwigo_ng/app.dart';
import 'package:piwigo_ng/components/buttons/animated_app_button.dart';
import 'package:piwigo_ng/components/snackbars.dart';
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
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

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
    if (url == null) return;
    url = url.split('//').last;
    url = url.substring(0, url.lastIndexOf('/'));
    _urlController.text = url;
    _usernameController.text = await storage.read(key: 'SERVER_USERNAME') ?? '';
    _passwordController.text = await storage.read(key: 'SERVER_PASSWORD') ?? '';
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) setState(() {});
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
    showErrorSnackBar(message: result.error.toString());
    _btnController.error();
    setState(() {
      if (result.error == ApiErrors.wrongLoginId) {
        _idError = true;
      } else if (result.error == ApiErrors.wrongServerUrl) {
        _urlError = true;
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
        '${_isSecured ? 'https' : 'http'}://${_urlController.text}/',
        _usernameController.text,
        _passwordController.text,
      );
      if (result.error != null) {
        _onLoginError(result);
      } else {
        await _onLoginSuccess(result);
      }
    } on Error catch (e) {
      debugPrint(e.toString());
      _btnController.error();
      showErrorSnackBar(message: "An error occurred");
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
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            controller: _urlController,
            onChanged: (value) {
              bool isError = !_urlValidator(value);
              if (_urlError != isError) {
                setState(() {
                  _urlError = isError;
                });
              }
            },
            textInputAction: TextInputAction.next,
            icon: const Icon(Icons.public),
            hint: 'example.piwigo.com',
            error: _urlError,
            prefix: _securedPrefix(),
            suffix: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('/', style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
          AppField(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            controller: _usernameController,
            onChanged: (value) {
              if (_idError) {
                setState(() {
                  _idError = false;
                });
              }
            },
            textInputAction: TextInputAction.next,
            hint: "username",
            error: _idError,
            enableClearAction: true,
            icon: const Icon(Icons.person),
          ),
          AppField(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            controller: _passwordController,
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
            child: AnimatedAppButton(
              controller: _btnController,
              disabled: _urlError,
              color: Theme.of(context).primaryColor,
              onPressed: _onLogin,
              child: Text(
                "Login", // Todo: Use translations
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _securedPrefix() {
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
