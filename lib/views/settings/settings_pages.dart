import 'package:flutter/material.dart';
import 'package:piwigo_ng/views/settings/privacy_policy_view_page.dart';
import 'package:piwigo_ng/views/settings/settings_album_thumbnail_page.dart';
import 'package:piwigo_ng/views/settings/settings_view_page.dart';
import 'package:piwigo_ng/views/unknown_route_page.dart';

Route<dynamic> generateSettingsRoutes(RouteSettings settings) {
  Map<String, dynamic> arguments = {};
  if (settings.arguments != null) {
    arguments = settings.arguments as Map<String, dynamic>;
  }

  switch (settings.name) {
    case SettingsViewPage.routeName:
      return MaterialPageRoute(
        builder: (_) => SettingsViewPage(),
        settings: settings,
      );
    case SettingsAlbumThumbnailPage.routeName:
      return MaterialPageRoute(
        builder: (_) => SettingsAlbumThumbnailPage(),
        settings: settings,
      );
    case PrivacyPolicyViewPage.routeName:
      return MaterialPageRoute(
        builder: (_) => const PrivacyPolicyViewPage(),
        settings: settings,
      );
    default:
      return MaterialPageRoute(
        builder: (_) => UnknownRoutePage(
          route: settings,
        ),
        settings: settings,
      );
  }
}
