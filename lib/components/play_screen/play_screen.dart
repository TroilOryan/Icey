import 'package:IceyPlayer/components/play_screen/landscape/landscape.dart';
import 'package:IceyPlayer/components/play_screen/play_screen_background.dart';
import 'package:IceyPlayer/components/play_screen/portrait/portrait.dart';
import 'package:IceyPlayer/components/play_screen/state.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

final playScreenState = PlayScreenState();

class PlayScreen extends StatefulWidget {
  final bool panelOpened;
  final VoidCallback onClosePanel;

  const PlayScreen({
    super.key,
    required this.panelOpened,
    required this.onClosePanel,
  });

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  void handleOpenLyric(BuildContext context) {
    if (settingsManager.immersive.value) return;

    playScreenState.offset.value = playScreenState.lyricOpened.value
        ? 0
        : MediaQuery.of(context).size.width;

    playScreenState.lyricOpened.value = !playScreenState.lyricOpened.value;
  }

  @override
  Widget build(BuildContext context) {
    final lyricOpened = playScreenState.lyricOpened.watch(context),
        offset = playScreenState.offset.watch(context);

    return Scaffold(
      body: Stack(
        children: [
          PlayScreenBackground(),
          OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.landscape) {
                return Landscape();
              }

              return Portrait(
                offset: offset,
                lyricOpened: lyricOpened,
                onOpenLyric: handleOpenLyric,
              );
            },
          ),
        ],
      ),
    );
  }
}
