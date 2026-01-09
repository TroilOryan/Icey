import 'package:flutter/material.dart';

import 'common.dart';

class DominantColor {
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final bool isDarkBg;

  const DominantColor({
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.isDarkBg,
  });
}

class DominantColorHelper {
  static Color getColor({required int dominantColor, required int textColor}) {
    late final Color baseColor;

    baseColor = Color(textColor);

    final color = CommonHelper.blendColors(
      baseColor,
      dominantColor == -1 ? baseColor : Color(dominantColor),
      0.9,
      0.2,
    );

    return color;
  }

  static Color fadeOnBackgroundColor(
      Color originalColor,
      double opacity,
      Color bgColor,
      ) {
    final cr = (originalColor.r * 255.0).round() & 0xff,
        cg = (originalColor.g * 255.0).round() & 0xff,
        cb = (originalColor.b * 255.0).round() & 0xff;

    final br = (bgColor.r * 255.0).round() & 0xff,
        bg = (bgColor.g * 255.0).round() & 0xff,
        bb = (bgColor.b * 255.0).round() & 0xff;

    return Color.fromARGB(
      255,
      (cr * opacity + br * (1 - opacity)).round(),
      (cg * opacity + bg * (1 - opacity)).round(),
      (cb * opacity + bb * (1 - opacity)).round(),
    );
  }
}
