import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piwigo_ng/services/app_providers.dart';
import 'package:piwigo_ng/utils/overscroll_behavior.dart';
import 'package:piwigo_ng/utils/page_routes.dart';
import 'package:piwigo_ng/utils/themes.dart';
import 'package:piwigo_ng/views/album/album_view_page.dart';
import 'package:piwigo_ng/views/album/root_album_view_page.dart';
import 'package:piwigo_ng/views/authentication/login_view_page.dart';
import 'package:piwigo_ng/views/image/image_search_view_page.dart';
import 'package:piwigo_ng/views/image/image_view_page.dart';
import 'package:piwigo_ng/views/settings/privacy_policy_view_page.dart';
import 'package:piwigo_ng/views/settings/settings_view_page.dart';
import 'package:piwigo_ng/views/unknown_route_page.dart';
import 'package:piwigo_ng/views/upload/upload_view_page.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey appKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      builder: (themeNotifier) {
        return MaterialApp(
          title: 'Piwigo NG',
          key: appKey,
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: scaffoldMessengerKey,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('de'),
            Locale('fr'),
          ],
          themeMode: themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
          darkTheme: darkTheme,
          theme: lightTheme,
          builder: (context, child) {
            return ScrollConfiguration(
              behavior: OverscrollBehavior(),
              child: child!,
            );
          },
          onGenerateRoute: generateRoute,
          onGenerateInitialRoutes: (String route) {
            return [
              MaterialPageRoute(
                builder: (_) => const LoginViewPage(autoLogin: true),
              ),
            ];
          },
          initialRoute: '/login',
        );
      },
    );
  }
}

Route<dynamic> generateRoute(RouteSettings settings) {
  Map<String, dynamic> arguments = {};
  if (settings.arguments != null) {
    arguments = settings.arguments as Map<String, dynamic>;
  }
  switch (settings.name) {
    case LoginViewPage.routeName:
      return MaterialPageRoute(
        builder: (_) => const LoginViewPage(),
        settings: settings,
      );
    case RootAlbumViewPage.routeName:
      return MaterialPageRoute(
        builder: (_) => RootAlbumViewPage(
          albumId: arguments['albumId'] ?? "0",
          isAdmin: arguments['isAdmin'] ?? false,
        ),
        settings: settings,
      );
    case AlbumViewPage.routeName:
      return MaterialPageRoute(
        builder: (_) => AlbumViewPage(
          album: arguments['album'],
          isAdmin: arguments['isAdmin'] ?? false,
        ),
        settings: settings,
      );
    case ImageSearchViewPage.routeName:
      return SlideUpPageRoute(
        page: const ImageSearchViewPage(),
        settings: settings,
      );
    case SettingsViewPage.routeName:
      return MaterialPageRoute(
        builder: (_) => const SettingsViewPage(),
        settings: settings,
      );
    case PrivacyPolicyViewPage.routeName:
      return MaterialPageRoute(
        builder: (_) => const PrivacyPolicyViewPage(),
        settings: settings,
      );
    case UploadViewPage.routeName:
      return MaterialPageRoute(
        builder: (_) => UploadViewPage(
          imageData: arguments["images"] ?? <XFile>[],
          category: arguments["category"],
        ),
        settings: settings,
      );
    case ImageViewPage.routeName:
      return MaterialPageRoute(
        builder: (_) => ImageViewPage(
          imageList: arguments['images'] ?? [],
          startId: arguments['startId'],
          album: arguments['album'],
        ),
        settings: settings,
      );
    default:
      return MaterialPageRoute(
        builder: (_) => UnknownRoutePage(route: settings),
        settings: settings,
      );
  }
}
