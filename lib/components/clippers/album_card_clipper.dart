import 'dart:math';

import 'package:flutter/material.dart';

class AlbumCardClipper extends CustomClipper<Path> {
  final double anchorRadius;
  final double outerRadius;
  final bool isAdmin;

  const AlbumCardClipper({
    this.anchorRadius = 8,
    this.outerRadius = 16,
    this.isAdmin = false,
  });

  @override
  Path getClip(Size size) {
    final double width = size.width;
    final double height = size.height;
    final double rightAnchorHeight = min(size.height * 0.5, 100);

    // Start path
    Path path = Path();
    path.moveTo(height, 0);

    // Top Anchor
    path.arcToPoint(
      Offset(height + anchorRadius * 2, 0),
      radius: Radius.circular(anchorRadius),
      clockwise: false,
    );

    path.lineTo(width, 0);
    path.lineTo(width, height / 2 - rightAnchorHeight / 2);

    // Right anchor
    if (isAdmin) {
      path.arcToPoint(
        Offset(width - anchorRadius, height / 2 - rightAnchorHeight / 2 + anchorRadius),
        radius: Radius.circular(anchorRadius),
        clockwise: false,
      );
      path.lineTo(width - anchorRadius, height / 2 + rightAnchorHeight / 2 - anchorRadius);
      path.arcToPoint(
        Offset(width, height / 2 + rightAnchorHeight / 2),
        radius: Radius.circular(anchorRadius),
        clockwise: false,
      );
    }

    path.lineTo(width, height);
    path.lineTo(height + anchorRadius * 2, height);

    // Bottom Anchor
    path.arcToPoint(
      Offset(height, height),
      radius: Radius.circular(anchorRadius),
      clockwise: false,
    );

    // Left side
    path.lineTo(outerRadius, height);
    path.arcToPoint(
      Offset(0, height - outerRadius),
      radius: Radius.circular(outerRadius),
    );
    path.lineTo(0, outerRadius);
    path.arcToPoint(
      Offset(outerRadius, 0),
      radius: Radius.circular(outerRadius),
    );
    path.lineTo(height, 0);

    // Close
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BoxShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    // here are my custom shapes
    path.moveTo(size.width, size.height * 0.14);
    path.lineTo(size.width, size.height * 1.0);
    path.lineTo(size.width - (size.width * 0.99), size.height);
    path.close();

    canvas.drawShadow(path, Colors.black45, 3.0, false);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
