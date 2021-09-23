import 'package:flutter/material.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'dart:math' show pi;

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
  return ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    backgroundColor: MaterialStateProperty.all(
      Theme.of(context).colorScheme.primary
    ),
  );
}
ButtonStyle dialogButtonStyleDisabled(context) {
  return ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    backgroundColor: MaterialStateProperty.all(
      Theme.of(context).disabledColor
    ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).inputDecorationTheme.fillColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isOnLeft ? Theme.of(context).iconTheme.color : Colors.transparent,
                boxShadow: _switchIconShadow(true),
              ),
              child: Icon(Icons.apps_rounded,
                  color: isOnLeft ? Colors.white : Theme.of(context).iconTheme.color
              ),
            ),
            SizedBox(width: 5),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isOnLeft ? Colors.transparent : Theme.of(context).iconTheme.color,
                boxShadow: _switchIconShadow(false),
              ),
              child: Icon(Icons.description_rounded,
                  color: isOnLeft ? Theme.of(context).iconTheme.color : Colors.white
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedIconButton extends StatefulWidget {
  const AnimatedIconButton(this.icon, {Key key, this.isActive = false}) : super(key: key);

  final Widget icon;
  final bool isActive;

  @override
  _AnimatedIconButtonState createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> with TickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: -45,
    ).animate(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isActive) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return AnimatedBuilder(
      animation: _controller,
      child: widget.icon,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * (-pi / 90),
          child: child,
        );
      },
    );
  }
}

