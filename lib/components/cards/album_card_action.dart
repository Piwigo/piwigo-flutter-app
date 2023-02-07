import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AlbumCardAction extends StatelessWidget {
  const AlbumCardAction({
    Key? key,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.onPressed,
    this.autoClose = false,
  }) : super(key: key);

  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final bool autoClose;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      backgroundColor: backgroundColor ?? Theme.of(context).cardColor,
      onPressed: (_) {
        if (onPressed != null) {
          onPressed!();
        }
      },
      autoClose: autoClose,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Icon(
            icon,
            color: foregroundColor ?? const Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}
