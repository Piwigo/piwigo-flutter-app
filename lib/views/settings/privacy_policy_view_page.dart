import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyViewPage extends StatefulWidget {
  const PrivacyPolicyViewPage({Key? key}) : super(key: key);

  static const String routeName = '/privacy';

  @override
  State<PrivacyPolicyViewPage> createState() => _PrivacyPolicyViewPageState();
}

class _PrivacyPolicyViewPageState extends State<PrivacyPolicyViewPage> {
  bool _isLoading = false;
  double _loadingProgress = 0.0;
  late final String _url;

  @override
  void initState() {
    WebView.platform = AndroidWebView();
    _url = 'https://piwigo.org/mobile-apps-privacy-policy&webview&lang=en_EN';
    super.initState();
  }

  NavigationDecision _navigation(NavigationRequest request) {
    // if (request.url == 'https://github.com/Piwigo/Piwigo-Android') {
    //   return NavigationDecision.prevent;
    // }
    // if (request.url == 'https://github.com/Piwigo/Piwigo-Mobile') {
    //   return NavigationDecision.prevent;
    // }
    return NavigationDecision.prevent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.w500), // Todo: appbar title
        ),
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: Navigator.of(context).pop,
        ),
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl: _url,
            navigationDelegate: _navigation,
            // onProgress: (progress) {
            //   setState(() {
            //     _loadingProgress = progress / 100;
            //   });
            // },
            // onPageStarted: (url) {
            //   setState(() {
            //     _isLoading = true;
            //   });
            // },
            // onPageFinished: (url) {
            //   setState(() {
            //     _isLoading = false;
            //   });
            // },
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                value: _loadingProgress,
              ),
            ),
        ],
      ),
    );
  }
}
