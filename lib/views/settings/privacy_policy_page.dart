import 'package:flutter/material.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/settings.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  static const String routeName = '/settings/privacy';

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  late final String _url;
  var ctrl = WebViewController();

  @override
  void initState() {
    ctrl.loadRequest(Uri.parse( _url + appStrings.settings_privacyLocale));
    ctrl.setNavigationDelegate(_navigation as NavigationDelegate);
    _url = Settings.privacyPolicyUrl;
    super.initState();
  }

  NavigationDecision _navigation(NavigationRequest request) {
    return NavigationDecision.prevent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          appStrings.settings_privacy,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: this.ctrl),
        ],
      ),
    );
  }
}
