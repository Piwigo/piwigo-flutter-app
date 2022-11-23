import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/buttons/piwigo_button.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    Key? key,
    this.message,
    this.confirm,
    this.cancel,
  }) : super(key: key);
  final String? message;
  final Widget? confirm;
  final Widget? cancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      contentPadding: const EdgeInsets.all(16.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message != null)
            Text(
              message!,
              softWrap: true,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 16.0),
          confirm ??
              PiwigoButton(
                onPressed: () => Navigator.of(context).pop(true),
                color: Theme.of(context).primaryColor,
                text: appStrings.alertConfirmButton,
              ),
          const SizedBox(height: 8.0),
          cancel ??
              PiwigoButton(
                onPressed: () => Navigator.of(context).pop(false),
                color: Theme.of(context).cardColor,
                text: appStrings.alertCancelButton,
                style: Theme.of(context).textTheme.titleSmall,
              ),
        ],
      ),
    );
  }
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  String? message,
  Widget? confirm,
  Widget? cancel,
}) async {
  final bool? isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      message: message,
      confirm: confirm,
      cancel: cancel,
    ),
  );

  return isConfirm ?? false;
}
