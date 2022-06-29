import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:piwigo_ng/services/ThemeProvider.dart';
import 'package:piwigo_ng/services/UploadStatusProvider.dart';
import 'package:piwigo_ng/views/RootCategoryViewPage.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:provider/provider.dart';
import 'package:piwigo_ng/views/LoginViewPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  await getSharedPreferences();
  initLocalNotifications();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      builder: (context, _) {
        return ChangeNotifierProvider(
          create: (context) => UploadStatusNotifier(),
          builder: (context, _) {
            return MyApp();
          },
        );
      },
    ),
  );
}

Future<void> getSharedPreferences() async {
  API.prefs = await SharedPreferences.getInstance();
}

void initLocalNotifications() {
  API.localNotification = FlutterLocalNotificationsPlugin();
  final android = AndroidInitializationSettings('@mipmap/ic_launcher');
  final initSettings = InitializationSettings(android: android);
  API.localNotification.initialize(initSettings);
}


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: "Piwigo NG",
      // localeListResolutionCallback: (locales, supportedLocales) {
      //   debugPrint('device locales=$locales supported locales=$supportedLocales');
      //
      //   for (Locale locale in locales) {
      //     if (supportedLocales.contains(locale)) {
      //       return locale;
      //     }
      //   }
      //
      //   return Locale('en', 'US');
      // },
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('en', 'US'),
      theme: light,
      // theme: themeProvider.darkTheme ? dark : light,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if(settings.name == '/') return MaterialPageRoute(builder: (context) => LoginViewPage());
        if(settings.name == '/root') return MaterialPageRoute(builder: (context) => RootCategoryViewPage(isAdmin: settings.arguments));
        return MaterialPageRoute(builder: (context) => Container());
      },
    );
  }
}



