import 'package:piwigo_ng/views/CategoryViewPage.dart';
import 'package:piwigo_ng/views/FavoritesViewPage.dart';
import 'package:piwigo_ng/views/ImageViewPage.dart';
import 'package:piwigo_ng/views/LoginViewPage.dart';
import 'package:piwigo_ng/views/RootCategoryViewPage.dart';
import 'package:piwigo_ng/views/RootTagViewPage.dart';
import 'package:piwigo_ng/views/SettingsViewPage.dart';
import 'package:piwigo_ng/views/TagViewPage.dart';

class RoutePaths {
  static const String Login = LoginViewPage.routeName;
  static const String Settings = SettingsPage.routeName;
  static const String Categories = RootCategoryViewPage.routeName;
  static const String CategoryContent = CategoryViewPage.routeName;
  static const String Tags = RootTagViewPage.routeName;
  static const String TagContent = TagViewPage.routeName;
  static const String ImageView = ImageViewPage.routeName;
  static const String Favorites = FavoritesViewPage.routeName;
}