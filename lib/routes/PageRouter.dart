import 'package:flutter/material.dart';
import 'package:piwigo_ng/routes/RoutePaths.dart';
import 'package:piwigo_ng/views/LoginViewPage.dart';
import 'package:piwigo_ng/views/RootCategoryViewPage.dart';
import 'package:piwigo_ng/views/RootTagViewPage.dart';
import 'package:piwigo_ng/views/SettingsViewPage.dart';

class PageRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePaths.Tags:
        return MaterialPageRoute(builder: (_) => RootTagViewPage());
      case RoutePaths.Categories:
        return MaterialPageRoute(builder: (context) => RootCategoryViewPage(isAdmin: settings.arguments));
      case RoutePaths.Settings:
        return MaterialPageRoute (builder: (context) => SettingsPage());
      case RoutePaths.Login:
      default:
        return MaterialPageRoute (builder: (context) => LoginViewPage());
      //   return MaterialPageRoute(builder: (context) => Container());
    }
  }
}
