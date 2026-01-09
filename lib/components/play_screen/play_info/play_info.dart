import 'package:IceyPlayer/components/marquee/marquee.dart';
import 'package:IceyPlayer/components/play_like_button/play_like_button.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/event_bus/event_bus.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signals_flutter/signals_flutter.dart';

final _likedBox = Boxes.likedBox;

class PlayInfo extends StatelessWidget {
  final bool? lyricOpened;
  final bool panelOpened;

  const PlayInfo({super.key, this.lyricOpened, required this.panelOpened});

  Future<bool> handleLike(String? id, bool liked) async {
    if (id == null) {
      return liked;
    }

    if (liked) {
      _likedBox.delete(int.parse(id));
    } else {
      _likedBox.put(int.parse(id), true);
    }

    eventBus.fire(LikeMediaChange(id, !liked));

    return !liked;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final textTheme = Theme.of(context).textTheme;

    final themeExtension = AppThemeExtension.of(context);

    final immersive = settingsManager.immersive.watch(context);

    final info = RepaintBoundary(
      child: StreamBuilder(
        stream: mediaManager.mediaItem,
        builder: (context, snapshot) {
          final mediaItem = snapshot.data;

          return AnimatedSwitcher(
            duration: AppTheme.defaultDurationMid,
            child: SizedBox(
              width: lyricOpened == true
                  ? mediaQuery.size.width * 0.8 - 64.w - 16.w
                  : mediaQuery.size.width - 64.w,
              child: Column(
                spacing: 6.h,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 8.w,
                    children: [
                      Flexible(
                        child: Marquee(
                          disableAnimation: !panelOpened,
                          child: Text(
                            mediaItem?.title ?? "暂无歌曲",
                            style: textTheme.titleLarge?.copyWith(
                              leadingDistribution: TextLeadingDistribution.even,
                              color: themeExtension.primary,
                            ),
                          ),
                        ),
                      ),
                      lyricOpened == true
                          ? const SizedBox()
                          : PlayLikeButton(
                              key: ValueKey(mediaItem?.id),
                              id: mediaItem?.id,
                              color: themeExtension.primary,
                              size: 26.sp,
                              onTap: (liked) =>
                                  handleLike(mediaItem?.id, liked),
                            ),
                    ],
                  ),
                  Marquee(
                    disableAnimation: !panelOpened,
                    child: Text(
                      mediaItem?.artist ?? "未知歌手",
                      style: textTheme.bodyMedium?.copyWith(
                        color: themeExtension.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (lyricOpened != null) {
      return AnimatedPositioned(
        top: lyricOpened!
            ? mediaQuery.size.width * 0.25 / 2 + 64.h
            : mediaQuery.size.width * 1.2,
        left: lyricOpened! ? (48.w + mediaQuery.size.width * 0.2) : 32.w,
        curve: Curves.easeInOutSine,
        duration: AppTheme.defaultDurationMid,
        child: AnimatedOpacity(
          opacity: immersive ? 0 : 1,
          duration: AppTheme.defaultDurationMid,
          child: info,
        ),
      );
    }

    return info;
  }
}
