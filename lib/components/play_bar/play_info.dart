import 'package:IceyPlayer/components/adaptive_builder/adaptive_builder.dart';
import 'package:IceyPlayer/components/marquee/marquee.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';

import 'play_bar_lyric.dart';

/// 音乐信息
class PlayInfo extends StatelessWidget {
  const PlayInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final deviceWidth = MediaQuery.of(context).size.width;

    final info = StreamBuilder(
      stream: mediaManager.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;

        return Column(
          crossAxisAlignment: .start,
          mainAxisAlignment: .center,
          children: [
            Marquee(
              child: Text(
                mediaItem?.title ?? "暂无歌曲",
                style: theme.textTheme.titleSmall,
                overflow: .ellipsis,
                maxLines: 1,
                softWrap: true,
              ),
            ),

            const PlayBarLyric(),
          ],
        );
      },
    );

    return AdaptiveBuilder(
      mobile: (context) => Row(
        children: [
          Flexible(
            child: Padding(
              padding: const .symmetric(horizontal: 56),
              child: info,
            ),
          ),
        ],
      ),
      tablet: (context) => SizedBox(width: deviceWidth * 0.2, child: info),
    );
  }
}
