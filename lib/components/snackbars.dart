import 'package:flutter/material.dart';
import 'package:piwigo_ng/app.dart';

Future<void> showAppSnackBar({
  String message = '',
  Color color = Colors.white,
  SnackBarAction? action,
  Widget? icon,
}) async {
  App.scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      backgroundColor: color,
      action: action,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: PhysicalModel(
                shape: BoxShape.circle,
                color: Colors.white,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: icon,
                ),
              ),
            ),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> showErrorSnackBar({String message = ''}) async {
  showAppSnackBar(
    color: Colors.red,
    action: SnackBarAction(
      textColor: Colors.white,
      onPressed: () {},
      label: 'OK',
    ),
    icon: const Icon(
      Icons.remove_circle_outline,
      color: Colors.red,
      size: 24,
    ),
    message: message,
  );
}
