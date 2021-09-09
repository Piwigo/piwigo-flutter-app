import 'package:flutter/material.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';

class DialogButton extends StatelessWidget {
  const DialogButton({Key key, this.style, this.onPressed, this.child}) : super(key: key);

  final ButtonStyle style;
  final Widget child;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      child: TextButton(
        style: style ?? dialogButtonStyle(context),
        child: child ?? Text(appStrings(context).alertConfirmButton,
            style: TextStyle(fontSize: 16, color: Colors.white)
        ),
        onPressed: onPressed ?? () {},
      ),
    );
  }
}


ButtonStyle dialogButtonStyle(context) {
  var _theme = Theme.of(context);
  return ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    backgroundColor: MaterialStateProperty.all(_theme.accentColor),
  );
}

ButtonStyle dialogButtonStyleDisabled(context) {
  var _theme = Theme.of(context);
  return ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    backgroundColor: MaterialStateProperty.all(_theme.disabledColor),
  );
}