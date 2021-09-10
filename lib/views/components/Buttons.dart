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


class IconSwitch extends StatelessWidget {
  const IconSwitch({Key key, this.isOnLeft, this.onTap}) : super(key: key);

  final bool isOnLeft;
  final Function() onTap;

  List<BoxShadow> _switchIconShadow(bool isLeft) {
    if(isLeft) {
      if(isOnLeft) return [BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 3,
          offset: Offset(0, 1), // changes position of shadow
        )];
      else return [];
    } else {
      if(isOnLeft) return [];
      else return [BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 1,
        blurRadius: 3,
        offset: Offset(0, 1), // changes position of shadow
      )];
    }

  }

  @override
  Widget build(BuildContext context) {
    var _theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _theme.inputDecorationTheme.fillColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isOnLeft ? _theme.accentColor : Colors.transparent,
                boxShadow: _switchIconShadow(true),
              ),
              child: Icon(Icons.apps_rounded,
                  color: isOnLeft ? Colors.white : _theme.iconTheme.color
              ),
            ),
            SizedBox(width: 5),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isOnLeft ? Colors.transparent : _theme.accentColor,
                boxShadow: _switchIconShadow(false),
              ),
              child: Icon(Icons.description_rounded,
                  color: isOnLeft ? _theme.iconTheme.color : Colors.white
              ),
            ),
          ],
        ),
      ),
    );
  }
}
