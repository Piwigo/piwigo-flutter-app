import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:piwigo_ng/core/router/app_routes.dart';
import 'package:piwigo_ng/features/albums/domain/entities/album_entity.dart';
import 'package:piwigo_ng/features/albums/presentation/pages/album_page.dart';
import 'package:piwigo_ng/features/albums/presentation/pages/root_page.dart';
import 'package:piwigo_ng/features/authentication/presentation/pages/login_page.dart';
import 'package:piwigo_ng/features/authentication/presentation/pages/startup_page.dart';
import 'package:piwigo_ng/features/images/presentation/pages/image_search_page.dart';
import 'package:piwigo_ng/features/settings/presentation/pages/settings_page.dart';

part 'app_router.freezed.dart';

part 'page_route_arguments.dart';

class AppRouter {
  const AppRouter();

  Route<dynamic> generateRoute(RouteSettings settings) {
    PageRouteArguments? route = settings.arguments as PageRouteArguments?;

    switch (settings.name) {
      case AppRoutes.main:
        return MaterialPageRoute<void>(builder: (_) => const StartupPage());
      case AppRoutes.login:
        return MaterialPageRoute<void>(builder: (_) => const LoginPage());
      case AppRoutes.root:
        return MaterialPageRoute<void>(builder: (_) => const RootPage());
      case AppRoutes.settings:
        return MaterialPageRoute<void>(builder: (_) => const SettingsPage());
      case AppRoutes.searchImages:
        return MaterialPageRoute<void>(builder: (_) => const ImageSearchPage());
      case AppRoutes.album:
        final _AlbumPageArgs args = route as _AlbumPageArgs;
        return MaterialPageRoute<void>(builder: (_) => AlbumPage(album: args.album));
      default:
        return MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            body: Center(
              child: Text("No route defined for ${settings.name}"),
            ),
          ),
        );
    }
  }
}
