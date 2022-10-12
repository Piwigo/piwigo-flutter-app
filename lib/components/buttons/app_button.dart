import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    Key? key,
    this.margin,
    this.padding,
    this.color,
    this.onPressed,
    this.disabled = false,
    this.loading = false,
    this.text = '',
  }) : super(key: key);

  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? color;
  final Function()? onPressed;
  final bool disabled;
  final bool loading;
  final String text;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = disabled ? Theme.of(context).disabledColor : color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: disabled ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: margin,
        padding: padding,
        height: 50,
        constraints: const BoxConstraints(
          minWidth: 50,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: backgroundColor,
        ),
        alignment: Alignment.center,
        child: Builder(builder: (context) {
          if (loading) {
            return CircularProgressIndicator();
          }
          return Text(
            text,
            style: Theme.of(context).textTheme.titleSmall,
          );
        }),
      ),
    );
  }
}
