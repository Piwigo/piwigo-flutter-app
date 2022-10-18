import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:piwigo_ng/utils/resources.dart';

final ThemeData lightTheme = ThemeData.light().copyWith(
  primaryColor: AppColors.accent,
  primaryColorLight: AppColors.white,
  primaryColorDark: AppColors.black,
  errorColor: AppColors.error,
  disabledColor: AppColors.disabled,
  backgroundColor: AppColors.backgroundLight,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  dialogBackgroundColor: AppColors.backgroundLight,
  focusColor: AppColors.accent,
  splashColor: AppColors.accent.withOpacity(0.3),
  cardColor: AppColors.cardLight,
  colorScheme: const ColorScheme.highContrastLight(
    primary: AppColors.accent,
    secondary: AppColors.accent,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.accent,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundLight,
    iconTheme: IconThemeData(
      color: AppColors.accent,
    ),
    actionsIconTheme: IconThemeData(
      color: AppColors.accent,
    ),
    foregroundColor: AppColors.accent,
    titleTextStyle: TextStyle(fontSize: 20.0, color: AppColors.black),
  ),
  iconTheme: const IconThemeData(
    color: AppColors.accent,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.accent,
    foregroundColor: AppColors.white,
  ),
  buttonTheme: const ButtonThemeData(
    colorScheme: ColorScheme.light(
      primary: AppColors.accent,
    ),
    buttonColor: AppColors.accent,
  ),
  inputDecorationTheme: InputDecorationTheme(
    prefixStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.fieldDark,
    ),
    prefixIconColor: AppColors.prefix,
    fillColor: AppColors.fieldLight,
    focusColor: AppColors.accent,
    hintStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.normal,
      color: AppColors.disabled,
    ),
    labelStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.textGrey,
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.accent,
    selectionColor: AppColors.accent.withOpacity(0.3),
    selectionHandleColor: AppColors.accent,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: AppColors.transparent,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.all(AppColors.backgroundLight),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.accent;
      } else if (states.contains(MaterialState.disabled)) {
        return AppColors.disabled;
      }
      return AppColors.fieldLight;
    }),
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: AppColors.accent,
    inactiveTrackColor: AppColors.fieldLight,
    thumbColor: AppColors.backgroundLight,
    activeTickMarkColor: AppColors.transparent,
    inactiveTickMarkColor: AppColors.transparent,
    overlayColor: Colors.transparent,
  ),
  splashFactory: NoSplash.splashFactory,
  textTheme: TextTheme(
    labelSmall: GoogleFonts.roboto(
      fontSize: 11,
      color: AppColors.black,
      letterSpacing: 0,
    ),
    bodySmall: GoogleFonts.roboto(
      fontSize: 14,
      color: const Color(0x80000000),
    ),
    bodyMedium: GoogleFonts.roboto(
      fontSize: 14,
      color: AppColors.black,
      fontWeight: FontWeight.normal,
    ),
    bodyLarge: GoogleFonts.roboto(
      fontSize: 14,
      color: AppColors.black,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.roboto(
      fontSize: 16,
      color: AppColors.black,
      fontWeight: FontWeight.normal,
    ),
    titleMedium: GoogleFonts.roboto(
      fontSize: 16,
      color: AppColors.black,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: GoogleFonts.roboto(
      fontSize: 18,
      color: AppColors.accent,
      fontWeight: FontWeight.w500,
    ),
    displaySmall: GoogleFonts.roboto(
      fontSize: 16,
      color: AppColors.white,
      fontWeight: FontWeight.w500,
    ),
    displayMedium: GoogleFonts.roboto(
      fontSize: 20,
      color: AppColors.black,
      fontWeight: FontWeight.normal,
    ),
  ),
);

final ThemeData darkTheme = ThemeData.dark().copyWith(
  primaryColor: AppColors.accent,
  primaryColorLight: AppColors.white,
  primaryColorDark: AppColors.black,
  errorColor: AppColors.error,
  disabledColor: AppColors.disabled,
  backgroundColor: AppColors.backgroundDark,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  dialogBackgroundColor: AppColors.backgroundDark,
  focusColor: AppColors.accent,
  cardColor: AppColors.cardDark,
  colorScheme: const ColorScheme.highContrastDark(
    primary: AppColors.accent,
    secondary: AppColors.accent,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.accent,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundDark,
    iconTheme: IconThemeData(
      color: AppColors.accent,
    ),
    titleTextStyle: TextStyle(fontSize: 20.0, color: AppColors.white),
  ),
  iconTheme: const IconThemeData(
    color: AppColors.accent,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.accent,
    foregroundColor: AppColors.white,
  ),
  buttonTheme: const ButtonThemeData(
    colorScheme: ColorScheme.dark(
      primary: AppColors.accent,
    ),
    buttonColor: AppColors.accent,
  ),
  inputDecorationTheme: InputDecorationTheme(
    prefixStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.white,
    ),
    prefixIconColor: AppColors.white,
    fillColor: AppColors.fieldDark,
    focusColor: AppColors.accent,
    hintStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.normal,
      color: AppColors.disabled,
    ),
    labelStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.white,
    ),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: AppColors.accent,
    selectionColor: Color(0x4DFF7700),
    selectionHandleColor: AppColors.accent,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Colors.black.withOpacity(0),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.all(const Color(0x80FFFFFF)),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.accent;
      } else if (states.contains(MaterialState.disabled)) {
        return AppColors.disabled;
      }
      return AppColors.backgroundDark;
    }),
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: AppColors.accent,
    inactiveTrackColor: AppColors.fieldDark,
    thumbColor: Color(0xFF9E9E9E),
    activeTickMarkColor: Color(0x00000000),
    inactiveTickMarkColor: Color(0x00000000),
    overlayColor: Colors.transparent,
  ),
  splashFactory: NoSplash.splashFactory,
  textTheme: TextTheme(
    labelSmall: GoogleFonts.roboto(
      fontSize: 11,
      color: AppColors.white,
      letterSpacing: 0,
    ),
    bodySmall: GoogleFonts.roboto(
      fontSize: 14,
      color: const Color(0x80FFFFFF),
    ),
    bodyMedium: GoogleFonts.roboto(
      fontSize: 14,
      color: AppColors.white,
      fontWeight: FontWeight.normal,
    ),
    bodyLarge: GoogleFonts.roboto(
      fontSize: 14,
      color: AppColors.white,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: GoogleFonts.roboto(
      fontSize: 16,
      color: AppColors.white,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: GoogleFonts.roboto(
      fontSize: 18,
      color: AppColors.accent,
      fontWeight: FontWeight.w500,
    ),
    displaySmall: GoogleFonts.roboto(
      fontSize: 16,
      color: AppColors.white,
      fontWeight: FontWeight.w500,
    ),
  ),
);
