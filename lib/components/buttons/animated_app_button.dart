import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class AnimatedAppButton extends StatelessWidget {
  const AnimatedAppButton({
    Key? key,
    this.color,
    this.child,
    this.onPressed,
    this.disabled = false,
    required this.controller,
  }) : super(key: key);

  final RoundedLoadingButtonController controller;
  final Color? color;
  final Widget? child;
  final Function()? onPressed;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: disabled ? 0.5 : 1,
      child: SizedBox(
        height: 50,
        child: LayoutBuilder(builder: (context, constraints) {
          return RoundedLoadingButton(
            controller: controller,
            duration: const Duration(milliseconds: 300),
            completionDuration: const Duration(milliseconds: 300),
            animateOnTap: false,
            color: color,
            elevation: 0,
            borderRadius: 10,
            height: 50,
            width: constraints.maxWidth,
            onPressed: disabled ? () {} : onPressed,
            child: child ?? const SizedBox(),
          );
        }),
      ),
    );
  }
}
