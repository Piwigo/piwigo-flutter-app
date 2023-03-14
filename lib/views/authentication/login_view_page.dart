import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:piwigo_ng/app.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/views/settings/privacy_policy_view_page.dart';

import '../../components/buttons/app_text_button.dart';
import 'login_form_view.dart';

class LoginViewPage extends StatefulWidget {
  const LoginViewPage({Key? key, this.autoLogin = false}) : super(key: key);

  static const String routeName = '/login';

  final bool autoLogin;

  @override
  State<LoginViewPage> createState() => _LoginViewPageState();
}

class _LoginViewPageState extends State<LoginViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                width: MediaQuery.of(context).size.width * 0.8,
                constraints: constraints.copyWith(
                  minHeight: constraints.maxHeight,
                  maxHeight: double.infinity,
                  maxWidth: 400.0,
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
                            PrivacyPolicyViewPage.routeName,
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
