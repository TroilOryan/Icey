import 'dart:math';

import 'package:IceyPlayer/components/play_cover/play_cover.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "dart:ui" as ui;

/// 沉浸封面
class PlayImmersiveCover extends StatelessWidget {
  final bool? lyricOpened;
  final double? offset;
  final bool isLandscape;
  final double? size;

  const PlayImmersiveCover({
    super.key,
    this.offset,
    this.lyricOpened,
    this.isLandscape = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    final _size = size ?? deviceWidth;

    final mediaQuery = MediaQuery.of(context);

    final List<double> verticalStops = (isLandscape
        ? const [0, 0, 0.3, 1.0]
        : const [0.0, 0.0, 0.6, 1]);

    final alignmentX = (2 * 32.w / deviceWidth) - 1;

    final scale = max(1 - (offset ?? 0) / mediaQuery.size.width, 0.2);

    final double opacity = min(
      0 + (offset ?? 0) / 2 / mediaQuery.size.width,
      1,
    );

    Widget cover = AnimatedContainer(
      duration: AppTheme.defaultDuration,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: scale < 1
            ? BorderRadius.all(AppTheme.borderRadiusLg)
            : null,
      ),
      child: PlayCover(
        duration: AppTheme.defaultDurationLong,
        width: _size,
        height: _size,
      ),
    );

    Widget shader = ShaderMask(
      key: ValueKey(isLandscape),
      shaderCallback: (rect) {
        return ui.Gradient.linear(
          isLandscape ? Offset(0, rect.width) : Offset(rect.width / 2, 0),
          isLandscape
              ? Offset(rect.width, rect.width)
              : Offset(rect.width / 2, deviceWidth - 10.h),
          [
            Colors.white.withAlpha(0),
            Colors.white,
            Colors.white,
            Colors.white.withAlpha(0),
          ],
          verticalStops,
        );
      },
      child: cover,
    );

    return AnimatedScale(
      curve: Curves.easeInOutSine,
      duration: AppTheme.defaultDurationMid,
      alignment: Alignment(alignmentX, -0.5),
      scale: scale,
      child: AnimatedContainer(
        duration: AppTheme.defaultDuration,
        height: _size,
        margin: EdgeInsets.only(
          top: lyricOpened != null && lyricOpened!
              ? mediaQuery.size.width * 0.25 / 2 + 14.h
              : 0,
        ),
        child: Stack(
          children: [
            shader,
            // 保证缩小后没有shader
            AnimatedOpacity(
              opacity: opacity,
              duration: AppTheme.defaultDurationMid,
              child: AnimatedContainer(
                duration: AppTheme.defaultDurationMid,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(AppTheme.borderRadiusLg),
                ),
                child: PlayCover(
                  duration: AppTheme.defaultDurationLong,
                  width: _size,
                  height: _size,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
