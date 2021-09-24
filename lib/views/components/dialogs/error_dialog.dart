import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';

import 'piwigo_dialog.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({Key key, this.errorMessage = "", this.errorTitle}) : super(key: key);

  final String errorTitle;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return PiwigoDialog(
      title: errorTitle ?? appStrings(context).errorHUD_label,
      content: Center(
        child: Text(errorMessage, style: Theme.of(context).textTheme.subtitle1),
      ),
    );
  }
}