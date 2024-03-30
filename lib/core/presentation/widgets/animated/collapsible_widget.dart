import 'package:flutter/material.dart';
import 'package:piwigo_ng/core/utils/constants/ui_constants.dart';

class CollapsibleWidget extends StatelessWidget {
  const CollapsibleWidget({
    super.key,
    required this.child,
    this.expanded = true,
    this.alignment = Alignment.topCenter,
  });

  final bool expanded;
  final AlignmentGeometry alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: UIConstants.animationDurationShort,
      curve: Curves.ease,
      alignment: Alignment.topCenter,
      child: Builder(
        builder: (BuildContext context) {
          if (expanded) return child;
          return SizedBox.fromSize(
            size: const Size.fromHeight(0.0),
          );
        },
      ),
    );
  }
}
