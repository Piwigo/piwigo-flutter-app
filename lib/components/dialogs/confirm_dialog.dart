import 'package:flutter/material.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/resources.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    Key? key,
    this.title,
    this.message,
    this.confirm,
    this.cancel,
    this.confirmColor,
  }) : super(key: key);
  final String? title;
  final String? message;
  final String? confirm;
  final String? cancel;
  final Color? confirmColor;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: _title,
      titleTextStyle: Theme.of(context).textTheme.displayMedium,
      content: _message(context),
      actions: [
        TextButton(
          style: ButtonStyle(
            foregroundColor: WidgetStateColor.resolveWith(
              (states) => Theme.of(context).textTheme.bodySmall?.color ?? AppColors.disabled,
            ),
            overlayColor: WidgetStateColor.resolveWith(
              (states) => AppColors.accent.withOpacity(0.3),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancel ?? appStrings.alertCancelButton,
          ),
        ),
        TextButton(
          style: ButtonStyle(
            foregroundColor: WidgetStateColor.resolveWith(
              (states) => confirmColor ?? AppColors.accent,
            ),
            overlayColor: WidgetStateColor.resolveWith(
              (states) => AppColors.accent.withOpacity(0.3),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirm ?? appStrings.alertConfirmButton,
          ),
        ),
      ],
    );
  }

  Widget? get _title {
    if (title != null) {
      return Text(
        title!,
        textAlign: TextAlign.start,
      );
    }
    return null;
  }

  Widget? _message(BuildContext context) {
    if (message != null) {
      return Text(
        message!,
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return null;
  }
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  String? title,
  String? message,
  String? confirm,
  String? cancel,
  Color? confirmColor,
}) async {
  final bool? isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      title: title,
      message: message,
      confirm: confirm,
      cancel: cancel,
      confirmColor: confirmColor,
    ),
  );

  return isConfirm ?? false;
}
