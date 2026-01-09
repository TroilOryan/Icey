import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import "package:path/path.dart" as path;

class CommonHelper {
  static Text buildDuration(
    Duration duration, [
    Color? color,
    TextStyle? textStyle,
  ]) {
    String format = DateFormats.h_m_s;

    if (duration.inHours <= 0) {
      format = "mm:ss";
    }

    return Text(
      DateUtil.formatDateMs(duration.inMilliseconds, format: format),
      style: textStyle?.copyWith(color: color),
    );
  }

  static String buildDurationText(Duration duration) {
    String format = DateFormats.h_m_s;

    if (duration.inHours <= 0) {
      format = "mm:ss";
    }

    return DateUtil.formatDateMs(duration.inMilliseconds, format: format);
  }

  static int findClosestIndex(List<BigInt?> bigInts, BigInt? target) {
    if (bigInts.isEmpty || target == null) {
      return 0;
    }

    if (bigInts[bigInts.length - 1]! <= target) {
      return bigInts.length - 1;
    }

    for (int i = 0; i < bigInts.length - 1; i++) {
      if ((bigInts[i]! <= target && bigInts[i + 1]! >= target) ||
          (bigInts[i]! >= target && bigInts[i + 1]! <= target)) {
        return i;
      }
    }

    return 0;
  }

  static Size getTextSize(
    String text,
    TextStyle? style, {
    int? maxLines = 1,
    double? maxWidth,
  }) {
    TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: '...',
    );

    painter.layout(maxWidth: maxWidth ?? double.infinity);

    return painter.size;
  }

  static Color blendColors(
    Color color1,
    Color? color2,
    double opacity1,
    double opacity2,
  ) {
    if (color2 == null || color2.toARGB32() == 0) return color1;

    final color1R = ((color1.r * 255.0).round()) & 0xff,
        color1G = ((color1.g * 255.0).round()) & 0xff,
        color1B = ((color1.b * 255.0).round()) & 0xff,
        color2R = ((color2.r * 255.0).round()) & 0xff,
        color2G = ((color2.g * 255.0).round()) & 0xff,
        color2B = ((color2.b * 255.0).round()) & 0xff;

    final int red =
        ((color1R * opacity1 + color2R * opacity2) / (opacity1 + opacity2))
            .round();
    final int green =
        ((color1G * opacity1 + color2G * opacity2) / (opacity1 + opacity2))
            .round();
    final int blue =
        ((color1B * opacity1 + color2B * opacity2) / (opacity1 + opacity2))
            .round();

    return Color.fromRGBO(red, green, blue, 1.0);
  }

  static List<String> getParentFolders(List<String> filePaths) {
    List<String> parentFolders = [];
    for (String filePath in filePaths) {
      String parentFolder = path.dirname(filePath);
      if (!parentFolders.contains(parentFolder)) {
        parentFolders.add(parentFolder);
      }
    }
    return parentFolders;
  }
}
