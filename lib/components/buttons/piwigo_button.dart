import 'package:flutter/material.dart';
import 'package:piwigo_ng/utils/settings.dart';

class PiwigoButton extends StatelessWidget {
  const PiwigoButton({
    Key? key,
    this.margin,
    this.padding,
    this.color,
    this.onPressed,
    this.disabled = false,
    this.loading = false,
    this.text = '',
    this.style,
  }) : super(key: key);

  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? color;
  final TextStyle? style;
  final Function()? onPressed;
  final bool disabled;
  final bool loading;
  final String text;

  static const double buttonHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = disabled
        ? Theme.of(context).disabledColor
        : color ?? Theme.of(context).colorScheme.secondary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: margin,
        padding: padding,
        height: buttonHeight,
        constraints: const BoxConstraints(
          minWidth: buttonHeight,
          maxWidth: Settings.modalMaxWidth,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: backgroundColor,
        ),
        alignment: Alignment.center,
        child: Builder(builder: (context) {
          if (loading) {
            return CircularProgressIndicator();
          }
          return Text(
            text,
            style: style ?? Theme.of(context).textTheme.displaySmall,
          );
        }),
      ),
    );
  }
}
