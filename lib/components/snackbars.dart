import 'package:flutter/material.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/resources.dart';
import 'package:piwigo_ng/utils/themes.dart';

SnackBar piwigoSnackBar({
  String message = '',
  Color? color,
  SnackBarAction? action,
  Widget? icon,
}) {
  return SnackBar(
    backgroundColor: color ?? (appPreferences.getBool('THEME') == true ? darkTheme.cardColor : lightTheme.cardColor),
    action: action,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
    content: Row(
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: icon,
          ),
        Expanded(
          child: Text(
            message,
            softWrap: true,
            maxLines: 2,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

SnackBar errorSnackBar({String message = '', IconData? icon}) {
  return piwigoSnackBar(
    color: Colors.red,
    action: SnackBarAction(
      textColor: Colors.white,
      onPressed: () {},
      label: appStrings.alertOkButton,
    ),
    icon: Icon(
      icon ?? Icons.error,
      color: Colors.white,
      shadows: AppShadows.icon,
      size: 32,
    ),
    message: message,
  );
}

SnackBar successSnackBar({String message = '', IconData? icon}) {
  return piwigoSnackBar(
    color: Colors.green,
    action: SnackBarAction(
      textColor: Colors.white,
      onPressed: () {},
      label: appStrings.alertOkButton,
    ),
    icon: Icon(
      icon ?? Icons.check_circle,
      color: Colors.white,
      shadows: AppShadows.icon,
      size: 32,
    ),
    message: message,
  );
}

SnackBar warningSnackBar({String message = '', IconData? icon}) {
  return piwigoSnackBar(
    color: Colors.orange,
    action: SnackBarAction(
      textColor: Colors.white,
      onPressed: () {},
      label: appStrings.alertOkButton,
    ),
    icon: Icon(
      icon ?? Icons.warning,
      color: Colors.white,
      shadows: AppShadows.icon,
      size: 32,
    ),
    message: message,
  );
}
