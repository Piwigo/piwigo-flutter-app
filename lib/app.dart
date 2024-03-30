import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:piwigo_ng/core/router/app_router.dart';
import 'package:piwigo_ng/core/router/app_routes.dart';
import 'package:piwigo_ng/core/utils/themes/app_themes.dart';
import 'package:piwigo_ng/features/authentication/presentation/blocs/session_status/session_status_bloc.dart';
import 'package:piwigo_ng/features/settings/presentation/blocs/theme/current_theme_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  static const AppRouter _router = AppRouter();
  static const AppThemes _themes = AppThemes();

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey appKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<void>>[
        BlocProvider<CurrentThemeBloc>(
          create: (BuildContext context) => CurrentThemeBloc()..add(InitThemeEvent()),
        ),
        BlocProvider<SessionStatusBloc>(
          create: (BuildContext context) => SessionStatusBloc(),
        ),
      ],
      child: BlocListener<SessionStatusBloc, SessionStatusState>(
        listener: (BuildContext context, SessionStatusState state) => state.whenOrNull(
          loggedOut: () => navigatorKey.currentState?.pushNamedAndRemoveUntil(
            AppRoutes.login,
            (Route<dynamic> route) => false,
          ),
        ),
        child: BlocBuilder<CurrentThemeBloc, CurrentThemeState>(
          builder: (BuildContext context, CurrentThemeState themeState) {
            return MaterialApp(
              // title: 'Piwigo NG',
              debugShowCheckedModeBanner: false,
              key: appKey,
              navigatorKey: navigatorKey,
              scaffoldMessengerKey: scaffoldMessengerKey,
              localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              // locale: localNotifier.locale,
              themeMode: ThemeMode.light,
              darkTheme: _themes.dark,
              theme: _themes.light,
              // builder: (context, child) {
              //   EasyLoading.instance
              //     ..loadingStyle = EasyLoadingStyle.custom
              //     ..backgroundColor = Theme.of(context).scaffoldBackgroundColor
              //     ..indicatorColor = Theme.of(context).textTheme.bodyMedium?.color
              //     ..textColor = Theme.of(context).textTheme.bodyMedium?.color;
              //   return ScrollConfiguration(
              //     behavior: OverscrollBehavior(),
              //     child: EasyLoading.init().call(context, child),
              //   );
              // },
              onGenerateRoute: (RouteSettings settings) => _router.generateRoute(settings),
              initialRoute: AppRoutes.main,
              // onGenerateInitialRoutes: (String route) {
              //   return [
              //     MaterialPageRoute(
              //       builder: (_) => const LoginPage(autoLogin: true),
              //     ),
              //   ];
              // },
              // initialRoute: '/login',
            );
          },
        ),
      ),
    );
  }
}

// Route<dynamic> generateRoute(RouteSettings settings) {
//   Map<String, dynamic> arguments = {};
//   if (settings.arguments != null) {
//     arguments = settings.arguments as Map<String, dynamic>;
//   }
//
//   bool isAdmin = appPreferences.getBool(Preferences.isAdminKey) ?? false;
//
//   if (settings.name == null) {
//     debugPrint("no route name");
//     return MaterialPageRoute(
//       builder: (_) => UnknownRoutePage(route: settings),
//       settings: settings,
//     );
//   }
//
//   switch (settings.name) {
//     case LoginPage.routeName:
//       return MaterialPageRoute(
//         builder: (_) => const LoginPage(),
//         settings: settings,
//       );
//     case LoginSettingsPage.routeName:
//       return MaterialPageRoute(
//         builder: (_) => LoginSettingsPage(),
//         settings: settings,
//       );
//     case RootAlbumPage.routeName:
//       return MaterialPageRoute(
//         builder: (_) => RootAlbumPage(
//           albumId: arguments['albumId'] ?? 0,
//           isAdmin: arguments['isAdmin'] ?? isAdmin,
//         ),
//         settings: settings,
//       );
//     case AlbumPage.routeName:
//       return MaterialPageRoute(
//         builder: (_) => AlbumPage(
//           album: arguments['album'],
//           isAdmin: arguments['isAdmin'] ?? isAdmin,
//         ),
//         settings: settings,
//       );
//     case AlbumPrivacyPage.routeName:
//       return MaterialPageRoute(
//         builder: (_) => AlbumPrivacyPage(
//           album: arguments['album']!,
//         ),
//         settings: settings,
//       );
//     case ImageSearchPage.routeName:
//       return MaterialPageRoute(
//         builder: (_) => ImageSearchPage(
//           isAdmin: arguments['isAdmin'] ?? isAdmin,
//         ),
//         settings: settings,
//       );
//     case ImageFavoritesPage.routeName:
//       return MaterialPageRoute(
//         builder: (_) => ImageFavoritesPage(
//           isAdmin: arguments['isAdmin'] ?? isAdmin,
//         ),
//         settings: settings,
//       );
//     case UploadPage.routeName:
//       return MaterialPageRoute(
//         builder: (_) => UploadPage(
//           imageList: arguments["images"] ?? <XFile>[],
//           albumId: arguments["category"],
//         ),
//         settings: settings,
//       );
//     case UploadStatusPage.routeName:
//       return MaterialPageRoute(
//         builder: (_) => UploadStatusPage(),
//         settings: settings,
//       );
//     case AutoUploadPage.routeName:
//       return MaterialPageRoute(
//         builder: (_) => AutoUploadPage(),
//         settings: settings,
//       );
//     case ImagePage.routeName:
//       return MaterialPageRoute<List<ImageModel>?>(
//         builder: (_) => ImagePage(
//           images: arguments['images'] ?? [],
//           startId: arguments['startId'],
//           album: arguments['album'],
//           isAdmin: arguments['isAdmin'] ?? isAdmin,
//         ),
//         settings: settings,
//       );
//     case VideoPlayerPage.routeName:
//       return MaterialPageRoute(
//         builder: (_) => VideoPlayerPage(
//           videoUrl: arguments['videoUrl'],
//           thumbnailUrl: arguments['thumbnailUrl'],
//         ),
//         settings: settings,
//       );
//     case EditImagePage.routeName:
//       return MaterialPageRoute<bool>(
//         builder: (_) => EditImagePage(
//           images: arguments['images'] ?? [],
//         ),
//         settings: settings,
//       );
//     case SettingsPage.routeName:
//       return MaterialPageRoute(
//         builder: (_) => SettingsPage(),
//         settings: settings,
//       );
//     case PrivacyPolicyPage.routeName:
//       return MaterialPageRoute(
//         builder: (_) => const PrivacyPolicyPage(),
//         settings: settings,
//       );
//     case SelectLanguagePage.routeName:
//       return MaterialPageRoute(
//         builder: (_) => const SelectLanguagePage(),
//         settings: settings,
//       );
//     default:
//       return MaterialPageRoute(
//         builder: (_) => UnknownRoutePage(route: settings),
//         settings: settings,
//       );
//   }
// }
