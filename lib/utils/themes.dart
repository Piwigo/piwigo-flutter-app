import 'package:flutter/material.dart';
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
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.fieldLight,
  ),
  colorScheme: const ColorScheme.highContrastLight(
    primary: AppColors.white,
    secondary: AppColors.accent,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.accent,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundLight,
    elevation: 0.0,
    scrolledUnderElevation: 5.0,
    iconTheme: IconThemeData(
      color: AppColors.accent,
    ),
    actionsIconTheme: IconThemeData(
      color: AppColors.accent,
    ),
    foregroundColor: AppColors.accent,
    titleTextStyle: TextStyle(fontSize: 20.0, color: AppColors.black),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: AppColors.accent,
    selectedLabelStyle: TextStyle(
      fontSize: 14,
      color: AppColors.accent,
      fontWeight: FontWeight.w500,
    ),
    unselectedItemColor: AppColors.black,
    unselectedLabelStyle: TextStyle(
      fontSize: 14,
      color: AppColors.black,
      fontWeight: FontWeight.normal,
    ),
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
    prefixStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.fieldDark,
    ),
    prefixIconColor: AppColors.prefix,
    fillColor: AppColors.fieldLight,
    focusColor: AppColors.accent,
    hintStyle: TextStyle(
      fontSize: 14,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.normal,
      color: AppColors.disabled,
    ),
    labelStyle: TextStyle(
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
    labelSmall: TextStyle(
      fontSize: 11,
      color: AppColors.black,
      letterSpacing: 0,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      color: const Color(0x80000000),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.black,
      fontWeight: FontWeight.normal,
    ),
    bodyLarge: TextStyle(
      fontSize: 14,
      color: AppColors.black,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      color: AppColors.black,
      fontWeight: FontWeight.normal,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      color: AppColors.black,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      color: AppColors.accent,
      fontWeight: FontWeight.w500,
    ),
    displaySmall: TextStyle(
      fontSize: 16,
      color: AppColors.white,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
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
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.fieldDark,
  ),
  colorScheme: const ColorScheme.highContrastDark(
    primary: AppColors.white,
    secondary: AppColors.accent,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.accent,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundDark,
    elevation: 0.0,
    scrolledUnderElevation: 5.0,
    iconTheme: IconThemeData(
      color: AppColors.accent,
    ),
    titleTextStyle: TextStyle(fontSize: 20.0, color: AppColors.white),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: AppColors.accent,
    selectedLabelStyle: TextStyle(
      fontSize: 14,
      color: AppColors.accent,
      fontWeight: FontWeight.w500,
    ),
    unselectedItemColor: AppColors.white,
    unselectedLabelStyle: TextStyle(
      fontSize: 14,
      color: AppColors.white,
      fontWeight: FontWeight.normal,
    ),
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
    prefixStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.white,
    ),
    prefixIconColor: AppColors.white,
    fillColor: AppColors.fieldDark,
    focusColor: AppColors.accent,
    hintStyle: TextStyle(
      fontSize: 14,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.normal,
      color: AppColors.disabled,
    ),
    labelStyle: TextStyle(
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
    labelSmall: TextStyle(
      fontSize: 11,
      color: AppColors.white,
      letterSpacing: 0,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      color: const Color(0x80FFFFFF),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.white,
      fontWeight: FontWeight.normal,
    ),
    bodyLarge: TextStyle(
      fontSize: 14,
      color: AppColors.white,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      color: AppColors.white,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      color: AppColors.accent,
      fontWeight: FontWeight.w500,
    ),
    displaySmall: TextStyle(
      fontSize: 16,
      color: AppColors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
);
