import 'package:IceyPlayer/components/play_lyric/lyric_widget.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import 'controller.dart';

class PlayLyric extends StatefulWidget {
  final VoidCallback? onScroll;

  const PlayLyric({super.key, this.onScroll});

  @override
  State<PlayLyric> createState() => _PlayLyricState();
}

class _PlayLyricState extends State<PlayLyric> {
  final controller = PlayLyricController();

  @override
  void initState() {
    super.initState();

    controller.onInit();
  }

  @override
  void dispose() {
    controller.onDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final karaoke = settingsManager.karaoke.watch(context),
        fakeEnhanced = settingsManager.fakeEnhanced.watch(context);

    final isHighlight = controller.isHighlight.watch(context);

    return Builder(
      builder: (context) {
        return OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;

            return LyricWidget(
              controller: controller.lyricController,
              isLandscape: isLandscape,
              isHighlight: isHighlight,
            );
          },
        );
      },
    );
  }
}
