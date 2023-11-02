import 'package:flutter/material.dart';
import 'package:piwigo_ng/utils/resources.dart';

class NotificationDot extends StatelessWidget {
  const NotificationDot({Key? key, this.isShown = false}) : super(key: key);

  final bool isShown;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
      scale: isShown ? 1.0 : 0.0,
      child: CircleAvatar(
        radius: 4.0,
        backgroundColor: AppColors.error,
      ),
    );
  }
}
