import 'package:flutter/material.dart';
import 'package:poc_piwigo/services/theme/theme_provider.dart';
import 'package:poc_piwigo/views/RootCategoryViewPage.dart';
import 'package:provider/provider.dart';
import 'package:poc_piwigo/views/LoginViewPage.dart';


void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) {
          return MaterialApp(
            title: 'Piwigo',
            // theme: notifier.darkTheme ? dark : light,
            theme: light,
            initialRoute: '/',
            // routes: {
            //   '/': (context) => LoginViewPage(),
            //   '/root': (context) => RootCategoryViewPage()
            // },
            onGenerateRoute: (settings) {
              print(settings.arguments);
              if(settings.name == '/') return MaterialPageRoute(builder: (context) => LoginViewPage());
              if(settings.name == '/root') return MaterialPageRoute(builder: (context) => RootCategoryViewPage(isAdmin: settings.arguments));
              return MaterialPageRoute(builder: (context) => Container());
            },
          );
        }
      ),
    );
  }
}



