import 'package:IceyPlayer/components/next_button/next_button.dart';
import 'package:IceyPlayer/components/play_button/play_button.dart';
import 'package:IceyPlayer/components/play_list_button/play_list_button.dart';
import 'package:IceyPlayer/components/play_lyric/play_lyric.dart';
import 'package:IceyPlayer/components/play_mode_button/play_mode_button.dart';
import 'package:IceyPlayer/components/play_progress_bar/play_progress_bar.dart';
import 'package:IceyPlayer/components/prev_button/prev_button.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/pages/home/title_bar_action/title_bar_action.dart';
import 'package:IceyPlayer/pages/sub_pages/play_screen/play_info/play_info.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import './play_shaped_cover.dart';

class Tablet extends StatelessWidget {
  const Tablet({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;

    final appThemeExtension = AppThemeExtension.of(context);

    return Stack(
      children: [
        const TitleBarAction(immersive: true),
        SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsetsGeometry.only(left: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  color: appThemeExtension.secondary,
                  onPressed: () => context.pop(),
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  color: appThemeExtension.secondary,
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsGeometry.fromLTRB(32, 64, 32, 32),
          child: Column(
            spacing: 32,
            mainAxisAlignment: .spaceBetween,
            children: [
              Flexible(
                child: Row(
                  spacing: 64,
                  children: [
                    PlayShapedCover(size: deviceHeight * 0.6),
                    const Flexible(
                      child: Column(
                        children: [
                          PlayInfo(),
                          Flexible(child: PlayLyric()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                spacing: 32,
                children: [
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
                    spacing: 32,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PlayModeButton(
                        size: 24,
                        color: appThemeExtension.secondary,
                      ),
                      PrevButton(size: 24, color: appThemeExtension.primary),
                      PlayButton(
                        immersive: true,
                        size: 40,
                        color: appThemeExtension.primary,
                      ),
                      NextButton(size: 24, color: appThemeExtension.primary),
                      PlayListButton(
                        size: 24,
                        color: appThemeExtension.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
