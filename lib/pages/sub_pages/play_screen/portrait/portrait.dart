import 'dart:math';

import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../play_immersive_cover/play_immersive_cover.dart';
import '../play_info/play_info.dart';
import '../play_shaped_cover/play_shaped_cover.dart';
import 'action_bar.dart';
import 'lyric_page.dart';
import 'play_page.dart';

class Portrait extends StatelessWidget {
  final double offset;
  final bool lyricOpened;
  final Function(BuildContext) onOpenLyric;

  const Portrait({
    super.key,
    required this.offset,
    required this.lyricOpened,
    required this.onOpenLyric,
  });

  Widget buildPlayCover({
    required double offset,
    required VoidCallback onTap,
    required double deviceWidth,
  }) => Builder(
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
  );

  @override
  Widget build(BuildContext context) {
    final paddingBottom = MediaQuery.of(context).padding.bottom;

    final deviceWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(bottom: max(paddingBottom, 16)),
      child: Stack(
        children: [
          buildPlayCover(
            offset: offset,
            onTap: () => onOpenLyric(context),
            deviceWidth: deviceWidth,
          ),
          PlayInfo(lyricOpened: lyricOpened),
          LyricPage(lyricOpened: lyricOpened),
          PlayPage(lyricOpened: lyricOpened, onOpenLyric: onOpenLyric),
          ActionBar(),
        ],
      ),
    );
  }
}
