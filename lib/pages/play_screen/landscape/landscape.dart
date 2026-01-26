import 'package:IceyPlayer/components/next_button/next_button.dart';
import 'package:IceyPlayer/components/play_button/play_button.dart';
import 'package:IceyPlayer/components/play_list_button/play_list_button.dart';
import 'package:IceyPlayer/components/play_lyric/play_lyric.dart';
import 'package:IceyPlayer/components/play_menu_button/play_menu_button.dart';
import 'package:IceyPlayer/components/play_progress_bar/play_progress_bar.dart';
import 'package:IceyPlayer/components/prev_button/prev_button.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../play_immersive_cover/play_immersive_cover.dart';
import '../play_info/play_info.dart' show PlayInfo;
import '../play_shaped_cover/play_shaped_cover.dart';

class Landscape extends StatelessWidget {

  const Landscape({super.key});

  Widget buildPlayCover({
    required VoidCallback onTap,
    required double deviceHeight,
  }) => Builder(
    builder: (context) {
      final coverShape = settingsManager.coverShape.watch(context);

      final immersive = computed(
        () => coverShape.value == CoverShape.immersive.value,
      );

      final height = immersive.value ? deviceHeight : deviceHeight - 32;

      Widget child;

      if (immersive.value) {
        child = PlayImmersiveCover(isLandscape: true, size: height);
      } else {
        child = Container(
          margin: EdgeInsets.only(top: 32),
          child: PlayShapedCover(isLandscape: true),
        );
      }

      return GestureDetector(onTap: onTap, child: child);
    },
  );

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;

    final appThemeExtension = AppThemeExtension.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: [
        buildPlayCover(onTap: () {}, deviceHeight: deviceHeight),
        Flexible(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 32, 24, 8),
            child: Column(
              children: [
                PlayInfo(),
                SizedBox(height: 8),
                Flexible(child: PlayLyric()),
                SizedBox(height: 16),
                StreamBuilder(
                  stream: mediaManager.mediaItem,
                  builder: (context, snapshot) {
                    final mediaItem = snapshot.data;

                    return PlayProgressBar(
                      quality: mediaItem?.extras?["quality"],
                      onChangeEnd: mediaManager.seek,
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PlayListButton(size: 24, color: appThemeExtension.primary),
                    PrevButton(size: 24, color: appThemeExtension.primary),
                    SizedBox(width: 8),
                    PlayButton(size: 40, color: appThemeExtension.primary),
                    SizedBox(width: 8),
                    NextButton(size: 24, color: appThemeExtension.primary),
                    PlayMenuButton(size: 24, color: appThemeExtension.primary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
