import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:piwigo_ng/app.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/settings.dart';
import 'package:piwigo_ng/views/settings/privacy_policy_page.dart';

import '../../components/buttons/app_text_button.dart';
import 'login_form_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, this.autoLogin = false}) : super(key: key);

  static const String routeName = '/login';

  final bool autoLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                constraints: constraints.copyWith(
                  minHeight: constraints.maxHeight,
                  maxHeight: double.infinity,
                  maxWidth: Settings.modalMaxWidth,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(
                        height: constraints.maxHeight * 0.33,
                        child: Center(
                          child: Image.asset(
                            "assets/logo/piwigo_logo.png",
                            fit: BoxFit.scaleDown,
                            errorBuilder: (context, o, s) {
                              return const Text(
                                "Piwigo",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: LoginFormView(
                          autoLogin: widget.autoLogin,
                        ),
                      ),
                      AppTextButton(
                        text: appStrings.settings_privacy,
                        onPressed: () {
                          App.navigatorKey.currentState?.pushNamed(
                            PrivacyPolicyPage.routeName,
                          );
                        },
                      ),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            PackageInfo packageInfo = snapshot.data!;
                            return Text(packageInfo.version);
                          }
                          return Text(appStrings.settings_unknownVersion);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
