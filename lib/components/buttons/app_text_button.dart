import 'package:flutter/material.dart';

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    Key? key,
    required this.text,
    this.style,
    this.onPressed,
    this.padding,
  }) : super(key: key);

  final String text;
  final TextStyle? style;
  final EdgeInsets? padding;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8.0,
            ),
        child: Text(
          text,
          style: style ??
              TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ), // Todo: Text button text style
        ),
      ),
    );
  }
}
