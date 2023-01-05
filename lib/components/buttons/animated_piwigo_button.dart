import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class AnimatedPiwigoButton extends StatelessWidget {
  const AnimatedPiwigoButton({
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
        height: 56.0,
        child: LayoutBuilder(builder: (context, constraints) {
          return RoundedLoadingButton(
            controller: controller,
            duration: const Duration(milliseconds: 500),
            completionDuration: const Duration(milliseconds: 300),
            // resetDuration: const Duration(seconds: 1),
            resetAfterDuration: false,
            animateOnTap: false,
            color: color,
            elevation: 0.0,
            borderRadius: 10.0,
            height: 56.0,
            width: constraints.maxWidth,
            onPressed: disabled ? () {} : onPressed,
            child: child ?? const SizedBox(),
          );
        }),
      ),
    );
  }
}
