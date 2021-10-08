import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/API.dart';


ThemeData light = ThemeData(
  brightness: Brightness.light,

  disabledColor: Color(0xff9e9e9e),
  primaryColor: Color(0xffeeeeee),
  dialogBackgroundColor: Color(0xffeeeeee),
  bottomAppBarColor: Color(0xffeeeeee),
  focusColor: Color(0xffff7700),
  backgroundColor: Color(0xffffffff),
  bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.black.withOpacity(0)),
  scaffoldBackgroundColor: Color(0xffeeeeee),
  cardColor: Color(0xffffffff),
  errorColor: Color(0xffff0e00),
  primaryColorLight: Color(0xffffffff),
  primaryColorDark: Color(0xff000000),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xffeeeeee),
    iconTheme: IconThemeData(
      color: Color(0xffff7700),
    ),
    titleTextStyle: TextStyle(fontSize: 20.0, color: Color(0xff000000)),
  ),
  colorScheme: ColorScheme.light(
    primary: Color(0xffff7700)
  ),

  iconTheme: IconThemeData(
    color: Color(0xffff7700),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xffff7000),
    foregroundColor: Color(0xffffffff),
  ),
  buttonTheme: ButtonThemeData(
    colorScheme: ColorScheme.light(
      primary: Color(0xffff7700),
    ),
    buttonColor: Color(0xffff7700),
  ),
  inputDecorationTheme: InputDecorationTheme(
    prefixStyle: TextStyle(color: Color(0xffff7700)),
    fillColor: Color(0xffe0e0e0),
    hintStyle: TextStyle(fontSize: 14,
        fontStyle: FontStyle.italic,
        color: Color(0xff9e9e9e)
    ),
    labelStyle: TextStyle(fontSize: 14, color: Color(0xff282828)),
  ),



  textTheme: TextTheme(
    headline1: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: Color(0xff000000)),
    headline2: TextStyle(fontSize: 26.0, color: Color(0xffffffff)),
    headline3: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold, color: Color(0xff000000)),
    headline4: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xffff7700)),
    headline5: TextStyle(fontSize: 16.0, color: Color(0xff000000)), // Text Fields
    headline6: TextStyle(fontSize: 16.0, color: Color(0xffff7700)),
    subtitle1: TextStyle(fontSize: 14.0, color: Color(0xff1d1d1d)),
    subtitle2: TextStyle(fontSize: 14.0, color: Color(0xff9e9e9e)),
    bodyText1: TextStyle(fontSize: 14.0, color: Color(0xff000000)),
    bodyText2: TextStyle(fontSize: 11.0, color: Color(0xff000000)),
  ),
);

ThemeData dark = ThemeData(
  brightness: Brightness.dark,

  disabledColor: Color(0xffe0e0e0),
  primaryColor: Color(0xff232323),
  dialogBackgroundColor: Color(0xff2D2D2D),
  bottomAppBarColor: Color(0xff232323),
  focusColor: Color(0xffff7700),
  // accentColor: Color(0xffff7700),
  backgroundColor: Color(0xff2D2D2D),
  // buttonColor: Color(0x30ff7700),
  scaffoldBackgroundColor: Color(0xff232323),
  cardColor: Color(0xffffffff),
  errorColor: Color(0xffff0e00),
  primaryColorLight: Color(0xffffffff),
  primaryColorDark: Color(0xff000000),

  iconTheme: IconThemeData(
    color: Color(0xffff7700),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0x30ff7700),
    foregroundColor: Color(0xffffffff),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Color(0xcbff7700),
  ),
  inputDecorationTheme: InputDecorationTheme(
    prefixStyle: TextStyle(color: Color(0xffff7700)),
    fillColor: Color(0xffefefef),
    hintStyle: TextStyle(fontSize: 14,
        fontStyle: FontStyle.italic,
        color: Color(0xff6f6f6f)
    ),
    labelStyle: TextStyle(fontSize: 14, color: Color(0xff393939))
  ),


  textTheme: TextTheme(
    headline1: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: Color(0xffffffff)),
    headline2: TextStyle(fontSize: 26.0, color: Color(0xffffffff)),
    headline3: TextStyle(fontSize: 26.0),
    headline4: TextStyle(fontSize: 26.0),
    headline5: TextStyle(fontSize: 14), // Text Fields
    headline6: TextStyle(fontSize: 20.0, color: Color(0xffff7700)),
    subtitle1: TextStyle(fontSize: 14.0, color: Color(0xff9e9e9e)),
    subtitle2: TextStyle(fontSize: 14.0),
    bodyText1: TextStyle(fontSize: 11.0),
    bodyText2: TextStyle(fontSize: 11.0, color: Color(0xffffffff)),
  ),
);

class ThemeNotifier extends ChangeNotifier {
  final String key = "theme";
  bool _darkTheme;
  bool get darkTheme => _darkTheme;

  ThemeNotifier() {
    _darkTheme = false;
    _loadFromPrefs();
  }

  toggleTheme(){
    _darkTheme = !_darkTheme;
    _saveToPrefs();
    notifyListeners();
  }

  _loadFromPrefs() {
    _darkTheme = API.prefs.getBool(key) ?? true;
    notifyListeners();
  }
  _saveToPrefs() {
    API.prefs.setBool(key, _darkTheme);
  }
}
