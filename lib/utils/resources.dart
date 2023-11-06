import 'package:flutter/material.dart';

class AppShadows {
  static final List<Shadow> icon = [
    Shadow(color: Colors.black26, blurRadius: 7, offset: Offset(1, 1)),
  ];
  static final List<BoxShadow> dragStack = [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 8,
      offset: const Offset(-1, -1),
    ),
  ];
}

class AppColors {
  static const Color accent = const Color(0xFFFF7700);
  static const Color white = const Color(0xFFFFFFFF);
  static const Color black = const Color(0xFF000000);
  static const Color error = const Color(0xFFE02318);
  static const Color success = const Color(0xFF4CAF50);
  static const Color disabled = const Color(0xFF9E9E9E);
  static const Color prefix = const Color(0xFF393939);
  static const Color textGrey = const Color(0xFF282828);
  static const Color transparent = const Color(0x00000000);

  static const Color backgroundLight = const Color(0xFFEEEEEE);
  static const Color backgroundDark = const Color(0xFF232323);
  static const Color fieldLight = const Color(0xFFE0E0E0);
  static const Color fieldDark = const Color(0xFF2D2D2D);
  static const Color cardLight = const Color(0xFFFFFFFF);
  static const Color cardDark = const Color(0xFF333333);

  static const Color lightGreen = const Color(0xFFD6FFCF);
  static const Color green = const Color(0xFF6ECE5E);
  static const Color lightOrange = const Color(0xFFFFE9CF);
  static const Color orange = const Color(0xFFFFA744);
  static const Color lightBlue = const Color(0xFFCFEBFF);
  static const Color blue = const Color(0xFF2883C3);
  static const Color lightPink = const Color(0xFFFFCFCF);
  static const Color pink = const Color(0xFFFF5252);

  static const List<Color> foregroundColors = [
    AppColors.green,
    AppColors.orange,
    AppColors.blue,
    AppColors.pink,
  ];
}
