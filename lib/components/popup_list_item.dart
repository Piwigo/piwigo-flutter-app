import 'package:flutter/material.dart';

class PopupListItem extends StatelessWidget {
  const PopupListItem({
    Key? key,
    this.icon,
    this.text,
    this.color,
  }) : super(key: key);

  final IconData? icon;
  final String? text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      iconColor: color ?? Theme.of(context).iconTheme.color,
      textColor: color,
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: 0,
      leading: Icon(icon),
      title: Text(
        text!,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
