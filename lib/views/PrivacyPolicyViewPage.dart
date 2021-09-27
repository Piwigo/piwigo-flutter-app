import 'package:flutter/material.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyViewPage extends StatefulWidget {
  const PrivacyPolicyViewPage({Key key}) : super(key: key);

  @override
  _PrivacyPolicyViewPageState createState() => _PrivacyPolicyViewPageState();
}
class _PrivacyPolicyViewPageState extends State<PrivacyPolicyViewPage> {
  bool _isLoading;
  double _loadingProgress;

  @override
  void initState() {
    WebView.platform = SurfaceAndroidWebView();
    _isLoading = false;
    _loadingProgress = 0.0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(appStrings(context).settings_privacy),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: _theme.iconTheme.color),
          onPressed: Navigator.of(context).pop,
        ),
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl: appStrings(context).settings_privacyUrl,
            onProgress: (progress) {
              print('PageView progress $progress');
              setState(() {
                _loadingProgress = progress/100;
              });
            },
            onPageStarted: (url) {
              setState(() {
                _isLoading = true;
              });
            },
            onPageFinished: (url) {
              setState(() {
                _isLoading = false;
              });
            },
          ),
          _isLoading ? Center(
            child: CircularProgressIndicator(
              value: _loadingProgress,
            ),
          ) : Text(""),
        ],
      ),
    );
  }
}
