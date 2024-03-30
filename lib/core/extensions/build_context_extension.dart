import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension BuildContextExtension on BuildContext {
  NavigatorState get navigator => Navigator.of(this);

  AppLocalizations get localizations => AppLocalizations.of(this)!;

  Size screenSize({bool safeArea = false}) {
    Size size = MediaQuery.of(this).size;
    if (!safeArea) return size;
    EdgeInsets safeAreaPadding = screenPadding;
    return Size(
      size.width - safeAreaPadding.horizontal,
      size.height - safeAreaPadding.vertical,
    );
  }

  EdgeInsets get screenPadding => MediaQuery.of(this).viewPadding;

  //region Themes
  ThemeData get theme => Theme.of(this);

  TextTheme get textStyles => Theme.of(this).textTheme;
//endregion
}
