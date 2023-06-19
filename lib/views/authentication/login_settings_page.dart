import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/sections/settings_section.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class LoginSettingsPage extends StatefulWidget {
  const LoginSettingsPage({Key? key}) : super(key: key);

  static const String routeName = '/login/settings';

  @override
  State<LoginSettingsPage> createState() => _LoginSettingsPageState();
}

class _LoginSettingsPageState extends State<LoginSettingsPage> {
  late String _basicAuthUsername;
  late String _basicAuthPassword;
  late bool _sslEnabled;
  late bool _basiAuth;

  @override
  void initState() {
    _basicAuthUsername =
        appPreferences.getString(Preferences.basicUsernameKey) ?? '';
    _basicAuthPassword =
        appPreferences.getString(Preferences.basicPasswordKey) ?? '';
    _sslEnabled = appPreferences.getBool(Preferences.enableSSLKey) ?? false;
    _basiAuth = appPreferences.getBool(Preferences.enableBasicAuthKey) ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appStrings.tabBar_preferences,
          textScaleFactor: 1,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 8.0,
        ),
        children: [
          SettingsSection(
            title: 'Invalid Certificates', // todo : translate
            children: [
              SettingsSectionItemSwitch(
                title: 'Enable SSL', // todo : translate
                value: _sslEnabled,
                onChanged: (value) => setState(() {
                  _sslEnabled = value;
                  appPreferences.setBool(
                    Preferences.enableSSLKey,
                    value,
                  );
                }),
              ),
            ],
          ),
          SettingsSection(
            title: 'HTTP Authorization', // todo : translate
            children: [
              SettingsSectionItemSwitch(
                title: 'Enable Basic Auth', // todo : translate
                value: _basiAuth,
                onChanged: (value) => setState(() {
                  _basiAuth = value;
                  appPreferences.setBool(
                    Preferences.enableBasicAuthKey,
                    value,
                  );
                }),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
                child: Builder(builder: (context) {
                  if (_basiAuth) {
                    return Column(
                      children: [
                        SettingsSectionItemField(
                          hint: 'Username', // todo : translate
                          value: _basicAuthUsername,
                          onChanged: (value) => setState(() {
                            _basicAuthUsername = value;
                            appPreferences.setString(
                              Preferences.basicUsernameKey,
                              value,
                            );
                          }),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                        ),
                        SettingsSectionItemField(
                          hint: 'Password', // todo : translate
                          value: _basicAuthPassword,
                          onChanged: (value) => setState(() {
                            _basicAuthPassword = value;
                            appPreferences.setString(
                              Preferences.basicPasswordKey,
                              value,
                            );
                          }),
                        ),
                      ],
                    );
                  }
                  return SizedBox.fromSize(
                    size: Size.fromHeight(0.0),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
