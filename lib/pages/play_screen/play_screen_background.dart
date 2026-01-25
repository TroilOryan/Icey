import 'package:IceyPlayer/pages/home/controller.dart';
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

    return Builder(
      builder: (context) {
        final highMaterial = settingsManager.highMaterial.watch(context),
            dynamicLight = settingsManager.dynamicLight.watch(context),
            artCover = settingsManager.artCover.watch(context);

        final blurValue = computed(() => highMaterial ? 48.0 : 24.0);

        final colorOpacity = computed(() => artCover ? 0.01 : 0.5);

        return Blur(
          blur: blurValue(),
          colorOpacity: colorOpacity(),
          overlay: dynamicLight
              ? AnimatedGradientBackground(
                  duration: const Duration(seconds: 30),
                  colors: [
                    theme.colorScheme.primary.withAlpha(155),
                    theme.colorScheme.secondary.withAlpha(155),
                    theme.colorScheme.surface.withAlpha(33),
                  ],
                  child: Container(),
                )
              : null,
          child: RepaintBoundary(
            child: Transform.flip(
              flipY: true,
              child: PlayCover(
                height: height,
                width: width,
                repeat: ImageRepeat.repeat,
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
        );
      },
    );
  }
}
