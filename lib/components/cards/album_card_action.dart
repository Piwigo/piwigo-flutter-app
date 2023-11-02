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

  static const double ICON_SIZE = 28.0;

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      padding: EdgeInsets.zero,
      backgroundColor: backgroundColor ?? Theme.of(context).cardColor,
      onPressed: (_) {
        if (onPressed != null) {
          onPressed!();
        }
      },
      autoClose: autoClose,
      child: Icon(
        icon,
        size: ICON_SIZE,
        color: foregroundColor ?? Colors.white,
      ),
    );
  }
}
