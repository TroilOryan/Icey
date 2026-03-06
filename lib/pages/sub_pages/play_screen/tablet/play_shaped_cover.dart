import 'dart:math';

import 'package:IceyPlayer/components/play_cover/play_cover.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

/// 圆形、方形、不规则
class PlayShapedCover extends StatelessWidget {
  final double size;

  const PlayShapedCover({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final mediaQuery = MediaQuery.of(context);

    final coverSize = size;

    final double paddingLeft = max(mediaQuery.padding.left, 32);

    final diskShadowColor = theme.colorScheme.secondaryContainer;

    final rotationAnimation = mediaManager.rotationAnimation.watch(context);

    return Builder(
      builder: (context) {
        final child = Builder(
          builder: (context) {
            final coverShape = settingsManager.coverShape.watch(context);

            if (coverShape == CoverShape.circle) {
              return RotationTransition(
                turns: rotationAnimation!,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: coverSize,
                      height: coverSize,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: diskShadowColor.withAlpha(13),
                            spreadRadius: 13,
                            blurRadius: 33,
                          ),
                        ],
                        border: Border.all(
                          width: 1,
                          color: diskShadowColor.withAlpha(22),
                        ),
                        shape: BoxShape.circle,
                        color: diskShadowColor.withAlpha(22),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      top: 24,
                      child: Container(
                        width: coverSize - 48,
                        height: coverSize - 48,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Image.asset(
                          'assets/images/music_back.png',
                          gaplessPlayback: true,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Positioned(
                      left: coverSize / 2 - coverSize / 4,
                      top: coverSize / 2 - coverSize / 4,
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: PlayCover(
                          noCover: true,
                          duration: AppTheme.defaultDurationLong,
                          width: coverSize / 2,
                          height: coverSize / 2,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (coverShape == CoverShape.rectangle) {
              return Container(
                key: ValueKey(coverSize),
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
                  width: coverSize - 8,
                  height: coverSize - 8,
                ),
              );
            } else if (coverShape == CoverShape.irregular) {
              return PlayCover(
                duration: AppTheme.defaultDurationLong,
                width: coverSize - 8,
                height: coverSize - 8,
              );
            }

            return const SizedBox();
          },
        );

        return child;
      },
    );
  }
}
