import 'package:IceyPlayer/components/play_screen/play_immersive_cover/play_immersive_cover.dart';
import 'package:IceyPlayer/components/play_screen/play_shaped_cover/play_shaped_cover.dart';
import 'package:IceyPlayer/components/play_screen/portrait/action_bar.dart';
import 'package:IceyPlayer/components/play_screen/portrait/lyric_page.dart';
import 'package:IceyPlayer/components/play_screen/portrait/play_page.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../play_info/play_info.dart';

class Portrait extends StatelessWidget {
  final double offset;
  final bool panelOpened;
  final bool lyricOpened;
  final Function(BuildContext) onOpenLyric;
  final VoidCallback onClosePanel;

  const Portrait({
    super.key,
    required this.offset,
    required this.panelOpened,
    required this.lyricOpened,
    required this.onOpenLyric,
    required this.onClosePanel,
  });

  Widget buildPlayCover({
    required double offset,
    required VoidCallback onTap,
    required double deviceWidth,
  }) => RepaintBoundary(
    child: Builder(
      builder: (context) {
        final coverShape = settingsManager.coverShape.watch(context);

        final immersive = computed(
          () => coverShape.value == CoverShape.immersive.value,
        );

        late final Widget child;

        if (immersive.value) {
          child = PlayImmersiveCover(lyricOpened: lyricOpened, offset: offset);
        } else {
          child = PlayShapedCover(offset: offset);
        }

        return GestureDetector(onTap: onTap, child: child);
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final paddingBottom = MediaQuery.of(context).padding.bottom;

    final deviceWidth = MediaQuery.of(context).size.width;

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: paddingBottom == 0 ? 16 : paddingBottom,
        ),
        child: Stack(
          children: [
            buildPlayCover(
              offset: offset,
              onTap: () => onOpenLyric(context),
              deviceWidth: deviceWidth,
            ),
            PlayInfo(panelOpened: panelOpened, lyricOpened: lyricOpened),
            LyricPage(lyricOpened: lyricOpened),
            PlayPage(
              panelOpened: panelOpened,
              lyricOpened: lyricOpened,
              onOpenLyric: onOpenLyric,
            ),
            ActionBar(onClosePanel: onClosePanel),
          ],
        ),
      ),
    );
  }
}
