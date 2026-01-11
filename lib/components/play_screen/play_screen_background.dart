import 'dart:ui';

import 'package:animated_gradient_background/animated_gradient_background.dart';
import 'package:blur/blur.dart';
import 'package:IceyPlayer/components/play_cover/play_cover.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class PlayScreenBackground extends StatelessWidget {
  const PlayScreenBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final width = MediaQuery.of(context).size.width,
        height = MediaQuery.of(context).size.height;

    return RepaintBoundary(
      child: Builder(
        builder: (context) {
          final double value = settingsManager.highMaterial.watch(context)
              ? 48
              : 24;

          final dynamicLight = settingsManager.dynamicLight.watch(context),
              artCover = settingsManager.artCover.watch(context);

          final child = Blur(
            blur: value,
            colorOpacity: artCover ? 0.01 : 0.5,
            child: RepaintBoundary(
              child: Transform.flip(
                flipY: true,
                child: Opacity(
                  opacity: 0.6,
                  child: PlayCover(
                    height: height,
                    width: width,
                    repeat: ImageRepeat.repeat,
                    fit: BoxFit.fitWidth,
                    filterQuality: FilterQuality.low,
                  ),
                ),
              ),
            ),
          );

          if (dynamicLight) {
            return RepaintBoundary(
              child: AnimatedGradientBackground(
                duration: const Duration(seconds: 6),
                colors: [
                  theme.colorScheme.primary.withAlpha(55),
                  theme.colorScheme.secondary.withAlpha(55),
                  theme.colorScheme.inversePrimary.withAlpha(55),
                ],
                child: child,
              ),
            );
          }

          return child;
        },
      ),
    );
  }
}
