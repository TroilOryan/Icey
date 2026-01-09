import 'dart:math';

import 'package:IceyPlayer/components/play_cover/play_cover.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signals/signals_flutter.dart';

/// 圆形、方形、不规则
class PlayShapedCover extends StatelessWidget {
  final double? offset;
  final bool isLandscape;

  const PlayShapedCover({super.key, this.offset, this.isLandscape = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final mediaQuery = MediaQuery.of(context);

    final size = isLandscape
        ? mediaQuery.size.height - 48.h
        : mediaQuery.size.width - 48.w;

    final diskShadowColor = theme.colorScheme.secondaryContainer;

    final rotationAnimation = mediaManager.rotationAnimation.watch(context);

    final scale = max(1 - (offset ?? 0) / mediaQuery.size.width, 0.25);

    final alignmentX = (2 * 16.w / size) - 1;

    // final alignmentY = (2 * (72.h - 24.w - 8.h) / size) - 1;

    final alignmentY = -0.5;

    // final alignmentY = 2 * mediaQuery.size.width * 0.25 / 2 + 64.h;

    final immersive = settingsManager.immersive.watch(context);

    return Builder(
      builder: (context) {
        final child = Builder(
          builder: (context) {
            final coverShape = settingsManager.coverShape.watch(context);

            if (coverShape == CoverShape.circle) {
              return RepaintBoundary(
                child: RotationTransition(
                  turns: rotationAnimation!,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      RepaintBoundary(
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: diskShadowColor.withAlpha(13),
                                spreadRadius: 13,
                                blurRadius: 33,
                              ),
                            ],
                            border: Border.all(
                              width: 1.w,
                              color: diskShadowColor.withAlpha(22),
                            ),
                            shape: BoxShape.circle,
                            color: diskShadowColor.withAlpha(22),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24.sp,
                        top: 24.sp,
                        child: Container(
                          width: size - 48.sp,
                          height: size - 48.sp,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            'assets/images/music_back.png',
                            gaplessPlayback: true,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Positioned(
                        left: size / 2 - size / 4,
                        top: size / 2 - size / 4,
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: PlayCover(
                            noCover: true,
                            duration: AppTheme.defaultDurationLong,
                            width: size / 2,
                            height: size / 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (coverShape == CoverShape.rectangle) {
              return Container(
                key: ValueKey(size),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: diskShadowColor.withAlpha(13),
                      spreadRadius: 13,
                      blurRadius: 33,
                    ),
                  ],
                  borderRadius: BorderRadius.all(AppTheme.borderRadiusLg),
                ),
                child: PlayCover(
                  duration: AppTheme.defaultDurationLong,
                  width: size - 8.w,
                  height: size - 8.w,
                ),
              );
            } else if (coverShape == CoverShape.irregular) {
              return PlayCover(
                duration: AppTheme.defaultDurationLong,
                width: size - 8.w,
                height: size - 8.w,
              );
            }

            return const SizedBox();
          },
        );

        if (isLandscape) {
          return Padding(
            padding: EdgeInsets.only(left: mediaQuery.padding.left),
            child: child,
          );
        }

        return RepaintBoundary(
          child: AnimatedSlide(
            curve: Curves.easeInOutSine,
            offset: Offset(0, immersive ? 0.2 : 0),
            duration: AppTheme.defaultDurationMid,
            child: AnimatedScale(
              curve: Curves.easeInOutSine,
              duration: AppTheme.defaultDurationMid,
              alignment: Alignment(alignmentX, alignmentY),
              scale: scale,
              child: AnimatedContainer(
                alignment: Alignment.center,
                width: mediaQuery.size.width,
                height: size,
                duration: AppTheme.defaultDuration,
                margin: EdgeInsets.only(
                  top: mediaQuery.size.width * 0.25 / 2 + 32.h,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
