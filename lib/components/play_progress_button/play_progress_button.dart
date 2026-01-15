import 'package:audio_service/audio_service.dart';
import 'package:IceyPlayer/components/play_button/play_button.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';

import 'play_progress_circle.dart';

class PlayProgressButton extends StatelessWidget {
  final double size;
  final Color? color;
  final Function(MediaItem? mediaItem)? onPressed;

  const PlayProgressButton({
    super.key,
    this.size = 24.0,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        StreamBuilder(
          stream: mediaManager.mediaItem,
          builder: (context, snapshot) {
            final durationMilliseconds =
                snapshot.data?.duration?.inMilliseconds;

            return StreamBuilder(
              stream: mediaManager.mediaStateStream,
              builder: (context, snapshot) {
                final positionMilliseconds =
                    snapshot.data?.position.inMilliseconds;

                final percent =
                    (durationMilliseconds != null &&
                        positionMilliseconds != null)
                    ? positionMilliseconds / durationMilliseconds
                    : 0.0;

                return PlayProgressCircle(
                  percent: percent,
                  color: color,
                  size: size * 2.2,
                );
              },
            );
          },
        ),
        PlayButton(ghost: true, size: size, color: color),
      ],
    );
  }
}
