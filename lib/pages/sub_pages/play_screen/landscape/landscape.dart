import 'package:IceyPlayer/components/next_button/next_button.dart';
import 'package:IceyPlayer/components/play_button/play_button.dart';
import 'package:IceyPlayer/components/play_list_button/play_list_button.dart';
import 'package:IceyPlayer/components/play_lyric/play_lyric.dart';
import 'package:IceyPlayer/components/play_menu_button/play_menu_button.dart';
import 'package:IceyPlayer/components/play_mode_button/play_mode_button.dart';
import 'package:IceyPlayer/components/play_progress_bar/play_progress_bar.dart';
import 'package:IceyPlayer/components/play_session_button/play_session_button.dart';
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
          margin: const EdgeInsets.only(top: 32),
          child: const PlayShapedCover(isLandscape: true),
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
            padding: const EdgeInsets.fromLTRB(0, 32, 24, 8),
            child: Column(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsetsGeometry.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        const PlayInfo(),
                        const SizedBox(height: 12),
                        const Flexible(child: PlayLyric()),
                        const SizedBox(height: 12),
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
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PlayModeButton(size: 22, color: appThemeExtension.secondary),
                    PlayListButton(size: 22, color: appThemeExtension.secondary),
                    PrevButton(size: 22, color: appThemeExtension.primary),
                    const SizedBox(width: 6),
                    PlayButton(size: 36, color: appThemeExtension.primary),
                    const SizedBox(width: 6),
                    NextButton(size: 22, color: appThemeExtension.primary),
                    PlaySessionButton(
                      size: 22,
                      color: appThemeExtension.secondary,
                    ),
                    PlayMenuButton(size: 22, color: appThemeExtension.secondary),
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
