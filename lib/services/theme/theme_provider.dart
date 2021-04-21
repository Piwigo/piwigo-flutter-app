import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



ThemeData light = ThemeData(
  brightness: Brightness.light,

  disabledColor: Color(0xff9e9e9e),
  primaryColor: Color(0xffeeeeee),
  dialogBackgroundColor: Color(0xffeeeeee),
  bottomAppBarColor: Color(0xffeeeeee),
  focusColor: Color(0xffff7700),
  accentColor: Color(0xffff7700),
  backgroundColor: Color(0xffffffff),
  buttonColor: Color(0xcbff7700),
  scaffoldBackgroundColor: Color(0xffeeeeee),
  cardColor: Color(0xffffffff),
  errorColor: Color(0xffff0e00),
  primaryColorLight: Color(0xffffffff),
  primaryColorDark: Color(0xff000000),

  iconTheme: IconThemeData(
    color: Color(0xffff7700),
  ),
  accentIconTheme: IconThemeData(
    color: Color(0xffffffff),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xbbff7000),
    foregroundColor: Color(0xffffffff),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Color(0xcbff7700),
  ),
  inputDecorationTheme: InputDecorationTheme(
    prefixStyle: TextStyle(color: Color(0xffff7700)),
    fillColor: Color(0xffe0e0e0),
    hintStyle: TextStyle(color: Color(0xff9e9e9e)),
  ),

  textTheme: TextTheme(
    headline1: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: Color(0xff000000)),
    headline2: TextStyle(fontSize: 26.0, color: Color(0xffffffff)),
    headline3: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xff000000)),
    headline4: TextStyle(fontSize: 16, color: Color(0xffff7700)),
    headline6: TextStyle(fontSize: 20.0, color: Color(0xffff7700)),
    subtitle1: TextStyle(fontSize: 14.0, color: Color(0xff9e9e9e)),
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
  accentColor: Color(0xffff7700),
  backgroundColor: Color(0xff2D2D2D),
  buttonColor: Color(0x30ff7700),
  scaffoldBackgroundColor: Color(0xff232323),
  cardColor: Color(0xffffffff),
  errorColor: Color(0xffff0e00),
  primaryColorLight: Color(0xffffffff),
  primaryColorDark: Color(0xff000000),

  iconTheme: IconThemeData(
    color: Color(0xffff7700),
  ),
  accentIconTheme: IconThemeData(
    color: Color(0xffffffff),
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
    fillColor: Color(0xffbdbdbd),
    hintStyle: TextStyle(color: Color(0xff9e9e9e)),
  ),


  textTheme: TextTheme(
    headline1: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: Color(0xffffffff)),
    headline2: TextStyle(fontSize: 26.0, color: Color(0xffffffff)),
    headline6: TextStyle(fontSize: 20.0, color: Color(0xffff7700)),
    subtitle1: TextStyle(fontSize: 14.0, color: Color(0xff9e9e9e)),
    bodyText2: TextStyle(fontSize: 11.0, color: Color(0xffffffff)),
  ),
);

class ThemeNotifier extends ChangeNotifier {
  final String key = "theme";
  SharedPreferences _pref;
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

  _initPrefs() async {
    if(_pref == null)
      _pref  = await SharedPreferences.getInstance();
  }
  _loadFromPrefs() async {
    await _initPrefs();
    _darkTheme = _pref.getBool(key) ?? true;
    notifyListeners();
  }
  _saveToPrefs() async {
    await _initPrefs();
    _pref.setBool(key, _darkTheme);
  }
}
