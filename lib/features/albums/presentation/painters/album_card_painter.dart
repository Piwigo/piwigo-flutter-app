import 'package:flutter/material.dart';
import 'package:piwigo_ng/core/extensions/build_context_extension.dart';
import 'package:piwigo_ng/core/utils/constants/ui_constants.dart';

class AlbumCardPainter extends CustomPainter {
  AlbumCardPainter({
    required this.context,
    this.showActions = false,
  });

  final bool showActions;
  final BuildContext context;

  static double anchorRadius = UIConstants.paddingXSmall;

  @override
  void paint(Canvas canvas, Size size) {
    double height = size.height;
    double width = size.width;

    Paint paint = Paint()..color = context.theme.cardColor;

    Path path = Path()
      ..lineTo(height, 0.0)
      ..arcToPoint(
        Offset(height + anchorRadius * 2, 0),
        radius: Radius.circular(anchorRadius),
        clockwise: false,
      )
      ..lineTo(width, 0.0)
      ..lineTo(width, height)
      ..lineTo(height + anchorRadius * 2, height)
      ..arcToPoint(
        Offset(height, height),
        radius: Radius.circular(anchorRadius),
        clockwise: false,
      )
      ..lineTo(0, height)
      ..close();

    canvas.drawPath(path, paint);

    if (showActions) {
      Paint indicatorPaint = Paint()..color = context.theme.colorScheme.secondary;

      Path indicatorPath = Path()
        ..moveTo(width, height / 4)
        ..arcToPoint(
          Offset(width - anchorRadius, (height / 4) + anchorRadius),
          radius: Radius.circular(anchorRadius),
          clockwise: false,
        )
        ..lineTo(width - anchorRadius, (height * 3 / 4) - anchorRadius)
        ..arcToPoint(
          Offset(width, height * 3 / 4),
          radius: Radius.circular(anchorRadius),
          clockwise: false,
        )
        ..close();

      canvas.drawPath(indicatorPath, indicatorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
