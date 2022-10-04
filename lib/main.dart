import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:open_file/open_file.dart';
import 'package:piwigo_ng/services/LocaleProvider.dart';
import 'package:piwigo_ng/services/ThemeProvider.dart';
import 'package:piwigo_ng/services/UploadStatusProvider.dart';
import 'package:piwigo_ng/views/RootCategoryViewPage.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:provider/provider.dart';
import 'package:piwigo_ng/views/LoginViewPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';


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
            return ChangeNotifierProvider(
              create: (context) => LocaleNotifier(),
              builder: (context, _) {
                return MyApp();
              }
            );
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
  API.localNotification.initialize(initSettings, onSelectNotification: onSelectNotification,);
}

Future<void> onSelectNotification(String payload) async {
  if(payload == null) return;
  OpenResult result = await OpenFile.open(payload);
  debugPrint(result.message);
}


class MyApp extends StatelessWidget {
  static final GlobalKey appKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeNotifier>(context);
    final localeProvider = Provider.of<LocaleNotifier>(context);
    return MaterialApp(
      key: appKey,
      title: "Piwigo NG",
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('de'),
        Locale('fr'),
        Locale('zh'),
      ],
      locale: localeProvider.locale,
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



