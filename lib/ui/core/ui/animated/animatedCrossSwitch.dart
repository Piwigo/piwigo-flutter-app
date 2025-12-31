import 'package:flutter/material.dart';

class AnimatedCrossSwitch extends StatelessWidget {
  const AnimatedCrossSwitch({
    Key? key,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.ease,
    this.isFirst = true,
    required this.first,
    required this.second,
  }) : super(key: key);

  final Duration duration;
  final Curve curve;
  final bool isFirst;
  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          ignoring: !isFirst,
          child: AnimatedScale(
            duration: duration,
            curve: curve,
            scale: isFirst ? 1 : 0,
            child: AnimatedOpacity(
              duration: duration,
              curve: curve,
              opacity: isFirst ? 1 : 0,
              child: first,
            ),
          ),
        ),
        IgnorePointer(
          ignoring: isFirst,
          child: AnimatedScale(
            duration: duration,
            curve: curve,
            scale: isFirst ? 0 : 1,
            child: AnimatedOpacity(
              duration: duration,
              curve: curve,
              opacity: isFirst ? 0 : 1,
              child: second,
            ),
          ),
        ),
      ],
    );
  }
}
