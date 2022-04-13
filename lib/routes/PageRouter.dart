import 'package:flutter/material.dart';
import 'package:piwigo_ng/model/PageArguments.dart';
import 'package:piwigo_ng/routes/RoutePaths.dart';
import 'package:piwigo_ng/views/CategoryViewPage.dart';
import 'package:piwigo_ng/views/ImageViewPage.dart';
import 'package:piwigo_ng/views/LoginViewPage.dart';
import 'package:piwigo_ng/views/RootCategoryViewPage.dart';
import 'package:piwigo_ng/views/RootTagViewPage.dart';
import 'package:piwigo_ng/views/SettingsViewPage.dart';
import 'package:piwigo_ng/views/TagViewPage.dart';

class PageRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as PageArguments;
    switch (settings.name) {

      case RoutePaths.ImageView:
        return MaterialPageRoute(builder: (_) => ImageViewPage(
            images: args.images, index: args.index, isAdmin: args.isAdmin,
            category: args.category, tag: args.tag,
          )
        );
      case RoutePaths.CategoryContent:
        return MaterialPageRoute(builder: (_) => CategoryViewPage());

      case RoutePaths.TagContent:
        return MaterialPageRoute(builder: (_) => TagViewPage(
              isAdmin: args.isAdmin, tag: args.tag, title: args.title
          )
        );
      case RoutePaths.Tags:
        return MaterialPageRoute(builder: (_) => RootTagViewPage());
      case RoutePaths.Categories:
        return MaterialPageRoute(builder: (context) => RootCategoryViewPage(isAdmin: args.isAdmin));
      case RoutePaths.Settings:
        return MaterialPageRoute (builder: (context) => SettingsPage());
      case RoutePaths.Login:
      default:
        return MaterialPageRoute (builder: (context) => LoginViewPage());
      //   return MaterialPageRoute(builder: (context) => Container());
    }
  }
}
