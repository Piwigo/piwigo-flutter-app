import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData.light().copyWith(
  primaryColor: const Color(0xffff7700),
  primaryColorLight: const Color(0xffffffff),
  primaryColorDark: const Color(0xff000000),
  errorColor: const Color(0xffff0e00),
  disabledColor: const Color(0xff9e9e9e),
  backgroundColor: const Color(0xffeeeeee),
  scaffoldBackgroundColor: const Color(0xffeeeeee),
  dialogBackgroundColor: const Color(0xffeeeeee),
  focusColor: const Color(0xffff7700),
  splashColor: const Color(0x4dff7700),
  cardColor: const Color(0xFFFFFFFF),
  colorScheme: const ColorScheme.highContrastLight(
    primary: Color(0xFFFF7700),
    secondary: Color(0xFFFF7700),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xffff7700),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xffeeeeee),
    iconTheme: IconThemeData(
      color: Color(0xffff7700),
    ),
    titleTextStyle: TextStyle(fontSize: 20.0, color: Color(0xff000000)),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xffff7700),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xffff7000),
    foregroundColor: Color(0xffffffff),
  ),
  buttonTheme: const ButtonThemeData(
    colorScheme: ColorScheme.light(
      primary: Color(0xffff7700),
    ),
    buttonColor: Color(0xffff7700),
  ),
  inputDecorationTheme: InputDecorationTheme(
    prefixStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: const Color(0xff2D2D2D),
    ),
    prefixIconColor: const Color(0xff393939),
    fillColor: const Color(0xffe0e0e0),
    focusColor: const Color(0xffff7700),
    hintStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.normal,
      color: const Color(0xff9e9e9e),
    ),
    labelStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: const Color(0xff282828),
    ),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xffff7700),
    selectionColor: Color(0x4dff7700),
    selectionHandleColor: Color(0xffff7700),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Colors.black.withOpacity(0),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.all(const Color(0xffeeeeee)),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xffff7700);
      } else if (states.contains(MaterialState.disabled)) {
        return const Color(0xff9e9e9e);
      }
      return const Color(0xffe0e0e0);
    }),
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: Color(0xffff7700),
    inactiveTrackColor: Color(0xffe0e0e0),
    thumbColor: Color(0xffeeeeee),
    activeTickMarkColor: Color(0x00000000),
    inactiveTickMarkColor: Color(0x00000000),
    overlayColor: Colors.transparent,
  ),
  splashFactory: NoSplash.splashFactory,
  textTheme: TextTheme(
    labelSmall: GoogleFonts.roboto(
      fontSize: 11,
      color: const Color(0xFF000000),
      letterSpacing: 0,
    ),
    bodySmall: GoogleFonts.roboto(
      fontSize: 14,
      color: const Color(0x80000000),
    ),
    bodyMedium: GoogleFonts.roboto(
      fontSize: 14,
      color: const Color(0xFF000000),
      fontWeight: FontWeight.normal,
    ),
    bodyLarge: GoogleFonts.roboto(
      fontSize: 14,
      color: const Color(0xFF000000),
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.roboto(
      fontSize: 16,
      color: const Color(0xFF000000),
      fontWeight: FontWeight.normal,
    ),
    titleMedium: GoogleFonts.roboto(
      fontSize: 16,
      color: const Color(0xFF000000),
      fontWeight: FontWeight.w500,
    ),
    titleLarge: GoogleFonts.roboto(
      fontSize: 18,
      color: const Color(0xffff7700),
      fontWeight: FontWeight.w500,
    ),
    displaySmall: GoogleFonts.roboto(
      fontSize: 16,
      color: const Color(0xffffffff),
      fontWeight: FontWeight.w500,
    ),
    displayMedium: GoogleFonts.roboto(
      fontSize: 20,
      color: const Color(0xFF000000),
      fontWeight: FontWeight.normal,
    ),
  ),
);

ThemeData darkTheme = ThemeData.dark().copyWith(
  primaryColor: const Color(0xFFFF7700),
  primaryColorLight: const Color(0xFFFFFFFF),
  primaryColorDark: const Color(0xFF000000),
  errorColor: const Color(0xFFFF0E00),
  disabledColor: const Color(0xFF9E9E9E),
  backgroundColor: const Color(0xFF232323),
  scaffoldBackgroundColor: const Color(0xFF232323),
  dialogBackgroundColor: const Color(0xFF232323),
  focusColor: const Color(0xFFFF7700),
  cardColor: const Color(0xFF333333),
  colorScheme: const ColorScheme.highContrastDark(
    primary: Color(0xFFFF7700),
    secondary: Color(0xFFFF7700),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFFFF7700),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF232323),
    iconTheme: IconThemeData(
      color: Color(0xFFFF7700),
    ),
    titleTextStyle: TextStyle(fontSize: 20.0, color: Color(0xFFFFFFFF)),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFFFF7700),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFFF7700),
    foregroundColor: Color(0xFFFFFFFF),
  ),
  buttonTheme: const ButtonThemeData(
    colorScheme: ColorScheme.dark(
      primary: Color(0xFFFF7700),
    ),
    buttonColor: Color(0xFFFF7700),
  ),
  inputDecorationTheme: InputDecorationTheme(
    prefixStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: const Color(0xFFFFFFFF),
    ),
    prefixIconColor: const Color(0xFFFFFFFF),
    fillColor: const Color(0xFF2D2D2D),
    focusColor: const Color(0xFFFF7700),
    hintStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.normal,
      color: const Color(0xFF9E9E9E),
    ),
    labelStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: const Color(0xFFFFFFFF),
    ),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xFFFF7700),
    selectionColor: Color(0x4DFF7700),
    selectionHandleColor: Color(0xFFFF7700),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Colors.black.withOpacity(0),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.all(const Color(0x80FFFFFF)),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFFFF7700);
      } else if (states.contains(MaterialState.disabled)) {
        return const Color(0xFF9E9E9E);
      }
      return const Color(0xFF232323);
    }),
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: Color(0xFFFF7700),
    inactiveTrackColor: Color(0xFF2D2D2D),
    thumbColor: Color(0xFF9E9E9E),
    activeTickMarkColor: Color(0x00000000),
    inactiveTickMarkColor: Color(0x00000000),
    overlayColor: Colors.transparent,
  ),
  splashFactory: NoSplash.splashFactory,
  textTheme: TextTheme(
    labelSmall: GoogleFonts.roboto(
      fontSize: 11,
      color: const Color(0xFFFFFFFF),
      letterSpacing: 0,
    ),
    bodySmall: GoogleFonts.roboto(
      fontSize: 14,
      color: const Color(0x80FFFFFF),
    ),
    bodyMedium: GoogleFonts.roboto(
      fontSize: 14,
      color: const Color(0xFFFFFFFF),
      fontWeight: FontWeight.normal,
    ),
    bodyLarge: GoogleFonts.roboto(
      fontSize: 14,
      color: const Color(0xFFFFFFFF),
      fontWeight: FontWeight.w500,
    ),
    titleMedium: GoogleFonts.roboto(
      fontSize: 16,
      color: const Color(0xFFFFFFFF),
      fontWeight: FontWeight.w500,
    ),
    titleLarge: GoogleFonts.roboto(
      fontSize: 18,
      color: const Color(0xffff7700),
      fontWeight: FontWeight.w500,
    ),
    displaySmall: GoogleFonts.roboto(
      fontSize: 16,
      color: const Color(0xffffffff),
      fontWeight: FontWeight.w500,
    ),
  ),
);

class AppTheme {
  final AppThemeColors colors;
  final AppThemeTextStyles textStyles;

  AppTheme({required this.colors, required this.textStyles});
}

class AppThemeColors {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color error;
  final Color success;
  final Color warning;
  final Color disabled;
  final Color card;
  final Color background;
  final Color field;

  AppThemeColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.error,
    required this.success,
    required this.warning,
    required this.disabled,
    required this.card,
    required this.background,
    required this.field,
  });
}

class AppThemeTextStyles {
  final TextStyle titlePrimary;
  final TextStyle titleSecondary;
  final TextStyle subtitle;
  final TextStyle sectionTitle;
  final TextStyle body;
  final TextStyle bodySmall;
  final TextStyle disabled;
  final TextStyle hint;
  final TextStyle buttonPrimary;
  final TextStyle buttonSecondary;

  const AppThemeTextStyles({
    required this.titlePrimary,
    required this.titleSecondary,
    required this.subtitle,
    required this.sectionTitle,
    required this.body,
    required this.bodySmall,
    required this.disabled,
    required this.hint,
    required this.buttonPrimary,
    required this.buttonSecondary,
  });
}
