import 'package:IceyPlayer/components/next_button/next_button.dart';
import 'package:IceyPlayer/components/play_button/play_button.dart';
import 'package:IceyPlayer/components/play_list_button/play_list_button.dart';
import 'package:IceyPlayer/components/play_menu_button/play_menu_button.dart';
import 'package:IceyPlayer/components/play_progress_bar/play_progress_bar.dart';
import 'package:IceyPlayer/components/play_screen/play_immersive_cover/play_immersive_cover.dart';
import 'package:IceyPlayer/components/play_screen/play_shaped_cover/play_shaped_cover.dart';
import 'package:IceyPlayer/components/prev_button/prev_button.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signals/signals_flutter.dart';

import '../../play_lyric/play_lyric.dart';
import '../play_info/play_info.dart' show PlayInfo;

class Landscape extends StatelessWidget {
  final bool panelOpened;

  const Landscape({super.key, required this.panelOpened});

  Widget buildPlayCover({
    required VoidCallback onTap,
    required double deviceHeight,
  }) => RepaintBoundary(
    child: Builder(
      builder: (context) {
        final coverShape = settingsManager.coverShape.watch(context);

        final immersive = computed(
          () => coverShape.value == CoverShape.immersive.value,
        );

        final height = immersive.value ? deviceHeight : deviceHeight - 32.h;

        Widget child;

        if (immersive.value) {
          child = PlayImmersiveCover(isLandscape: true, size: height);
        } else {
          child = Container(
            margin: EdgeInsets.only(top: 32.h),
            child: PlayShapedCover(isLandscape: true),
          );
        }

        return GestureDetector(onTap: onTap, child: child);
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;

    final appThemeExtension = AppThemeExtension.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24.w,
      children: [
        buildPlayCover(onTap: () {}, deviceHeight: deviceHeight),
        Flexible(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 32.h, 24.w, 8.h),
            child: Column(
              children: [
                PlayInfo(panelOpened: panelOpened),
                SizedBox(height: 8.h),
                Flexible(child: PlayLyric()),
                SizedBox(height: 16.h),
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
                    PlayListButton(
                      size: 24.sp,
                      color: appThemeExtension.primary,
                    ),
                    PrevButton(size: 24.sp, color: appThemeExtension.primary),
                    SizedBox(width: 8.w),
                    PlayButton(size: 40.sp, color: appThemeExtension.primary),
                    SizedBox(width: 8.w),
                    NextButton(size: 24.sp, color: appThemeExtension.primary),
                    PlayMenuButton(
                      size: 24.sp,
                      color: appThemeExtension.primary,
                    ),
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
