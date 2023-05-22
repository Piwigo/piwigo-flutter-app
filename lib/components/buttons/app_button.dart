import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    Key? key,
    this.margin,
    this.padding,
    this.color,
    this.child,
    this.onPressed,
    this.disabled = false,
  }) : super(key: key);

  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? color;
  final Widget? child;
  final Function()? onPressed;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = disabled
        ? Theme.of(context).disabledColor
        : color ?? Theme.of(context).colorScheme.primary;
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
        child: child,
      ),
    );
  }
}
