import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piwigo_ng/services/app_providers.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/overscroll_behavior.dart';
import 'package:piwigo_ng/utils/themes.dart';
import 'package:piwigo_ng/views/album/album_privacy_page.dart';
import 'package:piwigo_ng/views/album/album_view_page.dart';
import 'package:piwigo_ng/views/album/root_album_page.dart';
import 'package:piwigo_ng/views/authentication/login_page.dart';
import 'package:piwigo_ng/views/authentication/login_settings_page.dart';
import 'package:piwigo_ng/views/image/edit_image_page.dart';
import 'package:piwigo_ng/views/image/image_favorites_page.dart';
import 'package:piwigo_ng/views/image/image_page.dart';
import 'package:piwigo_ng/views/image/image_search_page.dart';
import 'package:piwigo_ng/views/image/video_player_page.dart';
import 'package:piwigo_ng/views/settings/auto_upload_page.dart';
import 'package:piwigo_ng/views/settings/privacy_policy_page.dart';
import 'package:piwigo_ng/views/settings/select_language_page.dart';
import 'package:piwigo_ng/views/settings/settings_page.dart';
import 'package:piwigo_ng/views/unknown_route_page.dart';
import 'package:piwigo_ng/views/upload/upload_page.dart';
import 'package:piwigo_ng/views/upload/upload_status_page.dart';

import 'models/image_model.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey appKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      builder: (localNotifier, themeNotifier) {
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
            Locale('es'),
            Locale('lt'),
            Locale('sk'),
            Locale('zh'),
          ],
          locale: localNotifier.locale,
          themeMode: themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
          darkTheme: darkTheme,
          theme: lightTheme,
          builder: (context, child) {
            EasyLoading.instance
              ..loadingStyle = EasyLoadingStyle.custom
              ..backgroundColor = Theme.of(context).scaffoldBackgroundColor
              ..indicatorColor = Theme.of(context).textTheme.bodyMedium?.color
              ..textColor = Theme.of(context).textTheme.bodyMedium?.color;
            return ScrollConfiguration(
              behavior: OverscrollBehavior(),
              child: EasyLoading.init().call(context, child),
            );
          },
          onGenerateRoute: generateRoute,
          onGenerateInitialRoutes: (String route) {
            return [
              MaterialPageRoute(
                builder: (_) => const LoginPage(autoLogin: true),
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

  bool isAdmin = appPreferences.getBool(Preferences.isAdminKey) ?? false;

  if (settings.name == null) {
    debugPrint("no route name");
    return MaterialPageRoute(
      builder: (_) => UnknownRoutePage(route: settings),
      settings: settings,
    );
  }

  switch (settings.name) {
    case LoginPage.routeName:
      return MaterialPageRoute(
        builder: (_) => const LoginPage(),
        settings: settings,
      );
    case LoginSettingsPage.routeName:
      return MaterialPageRoute(
        builder: (_) => LoginSettingsPage(),
        settings: settings,
      );
    case RootAlbumPage.routeName:
      return MaterialPageRoute(
        builder: (_) => RootAlbumPage(
          albumId: arguments['albumId'] ?? 0,
          isAdmin: arguments['isAdmin'] ?? isAdmin,
        ),
        settings: settings,
      );
    case AlbumPage.routeName:
      return MaterialPageRoute(
        builder: (_) => AlbumPage(
          album: arguments['album'],
          isAdmin: arguments['isAdmin'] ?? isAdmin,
        ),
        settings: settings,
      );
    case AlbumPrivacyPage.routeName:
      return MaterialPageRoute(
        builder: (_) => AlbumPrivacyPage(
          album: arguments['album']!,
        ),
        settings: settings,
      );
    case ImageSearchPage.routeName:
      return MaterialPageRoute(
        builder: (_) => ImageSearchPage(
          isAdmin: arguments['isAdmin'] ?? isAdmin,
        ),
        settings: settings,
      );
    case ImageFavoritesPage.routeName:
      return MaterialPageRoute(
        builder: (_) => ImageFavoritesPage(
          isAdmin: arguments['isAdmin'] ?? isAdmin,
        ),
        settings: settings,
      );
    case UploadPage.routeName:
      return MaterialPageRoute(
        builder: (_) => UploadPage(
          imageList: arguments["images"] ?? <XFile>[],
          albumId: arguments["category"],
        ),
        settings: settings,
      );
    case UploadStatusPage.routeName:
      return MaterialPageRoute(
        builder: (_) => UploadStatusPage(),
        settings: settings,
      );
    case AutoUploadPage.routeName:
      return MaterialPageRoute(
        builder: (_) => AutoUploadPage(),
        settings: settings,
      );
    case ImagePage.routeName:
      return MaterialPageRoute<List<ImageModel>?>(
        builder: (_) => ImagePage(
          images: arguments['images'] ?? [],
          startId: arguments['startId'],
          album: arguments['album'],
          isAdmin: arguments['isAdmin'] ?? isAdmin,
        ),
        settings: settings,
      );
    case VideoPlayerPage.routeName:
      return MaterialPageRoute(
        builder: (_) => VideoPlayerPage(
          videoUrl: arguments['videoUrl'],
          thumbnailUrl: arguments['thumbnailUrl'],
        ),
        settings: settings,
      );
    case EditImagePage.routeName:
      return MaterialPageRoute<bool>(
        builder: (_) => EditImagePage(
          images: arguments['images'] ?? [],
        ),
        settings: settings,
      );
    case SettingsPage.routeName:
      return MaterialPageRoute(
        builder: (_) => SettingsPage(),
        settings: settings,
      );
    case PrivacyPolicyPage.routeName:
      return MaterialPageRoute(
        builder: (_) => const PrivacyPolicyPage(),
        settings: settings,
      );
    case SelectLanguagePage.routeName:
      return MaterialPageRoute(
        builder: (_) => const SelectLanguagePage(),
        settings: settings,
      );
    default:
      return MaterialPageRoute(
        builder: (_) => UnknownRoutePage(route: settings),
        settings: settings,
      );
  }
}
