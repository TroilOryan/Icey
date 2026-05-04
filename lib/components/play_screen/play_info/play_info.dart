import 'package:IceyPlayer/components/marquee/marquee.dart';
import 'package:IceyPlayer/components/play_like_button/play_like_button.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/helpers/media/media.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class PlayInfo extends StatelessWidget {
  const PlayInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final themeExtension = AppThemeExtension.of(context);

    final immersive = settingsManager.immersive.watch(context);

    return StreamBuilder(
      stream: mediaManager.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;

        return AnimatedSwitcher(
          duration: AppTheme.defaultDurationMid,
          key: ValueKey(mediaItem?.id),
          child: Column(
            spacing: 6,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 8,
                children: [
                  Flexible(
                    child: Marquee(
                      child: Text(
                        mediaItem?.title ?? "暂无歌曲",
                        style: textTheme.titleLarge?.copyWith(
                          leadingDistribution: TextLeadingDistribution.even,
                          color: themeExtension.primary,
                        ),
                      ),
                    ),
                  ),
                  PlayLikeButton(
                    key: ValueKey(mediaItem?.id),
                    id: mediaItem?.id,
                    color: themeExtension.primary,
                    size: 26,
                    onTap: (liked) =>
                        MediaHelper.likeMedia(mediaItem?.id, liked),
                  ),
                ],
              ),
              Marquee(
                child: Text(
                  mediaItem?.artist ?? "未知歌手",
                  style: textTheme.bodyMedium?.copyWith(
                    color: themeExtension.secondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
