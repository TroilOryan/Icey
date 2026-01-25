import 'package:audio_service/audio_service.dart';
import 'package:IceyPlayer/components/marquee/marquee.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';

import 'play_bar_lyric.dart';

/// 音乐信息
class PlayInfo extends StatelessWidget {
  final MediaItem? mediaItem;

  const PlayInfo({
    super.key,
    required this.mediaItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        StreamBuilder(
          stream: mediaManager.mediaItem,
          builder: (context, snapshot) {
            final mediaItem = snapshot.data;

            return Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Marquee(
                      child: Text(
                        mediaItem?.title ?? "暂无歌曲",
                        style: theme.textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
                      ),
                    ),

                    PlayBarLyric(),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
