import 'dart:io';

import 'package:IceyPlayer/helpers/toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:path/path.dart" as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

class CommonHelper {
  static late final Directory tmpDir;

  static Text buildDuration(
    Duration duration, [
    Color? color,
    TextStyle? textStyle,
  ]) {
    return Text(
      buildDurationText(duration),
      style: textStyle?.copyWith(color: color),
    );
  }

  static String buildDurationText(Duration duration) {
    final int totalSeconds = duration.inSeconds;
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    if (hours <= 0) {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  static int findClosestIndex(List<int> values, int target) {
    if (values.isEmpty) {
      return 0;
    }

    if (target <= values.first) {
      return 0;
    }

    if (target >= values.last) {
      return values.length - 1;
    }

    int low = 0;
    int high = values.length - 1;

    while (low < high) {
      final mid = (low + high + 1) ~/ 2;
      if (values[mid] <= target) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }

    return low;
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

  static Future<void> copyText(
    String text, {
    bool needToast = true,
    String? toastText,
  }) {
    if (needToast) {
      showToast(toastText ?? '已复制');
    }
    return Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> launchURL(
    String url, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: mode)) {
        showToast('Could not launch $url');
      }
    } catch (e) {
      showToast(e.toString());
    }
  }

  Future<Directory> getAppDataDir() async {
    final dir = await getApplicationDocumentsDirectory();

    return Directory(
      path.join(dir.path, "icey_player"),
    ).create(recursive: true);
  }
}
