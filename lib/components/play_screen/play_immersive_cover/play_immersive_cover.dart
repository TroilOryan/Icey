import 'package:IceyPlayer/components/play_cover/play_cover.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import "dart:ui" as ui;

/// 沉浸封面
class PlayImmersiveCover extends StatelessWidget {
  final double size;

  const PlayImmersiveCover({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    Widget cover = PlayCover(
      duration: AppTheme.defaultDurationLong,
      width: size,
      height: size,
    );

    Widget shader = ShaderMask(
      shaderCallback: (rect) {
        return ui.Gradient.linear(
          Offset(rect.width / 2, 0),
          Offset(rect.width / 2, size - 10),
          [
            Colors.white.withAlpha(0),
            Colors.white,
            Colors.white,
            Colors.white.withAlpha(0),
          ],
          const [0.0, 0.0, 0.6, 1],
        );
      },
      child: cover,
    );

    return SizedBox(
      width: size,
      height: size,
      child: shader,
    );
  }
}
