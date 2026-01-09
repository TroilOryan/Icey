import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';

const playKey = ValueKey("play"), pauseKey = ValueKey("pause");

/// 播放/暂停按钮
class PlayButton extends StatelessWidget {
  final double size;
  final Color? color;
  final bool ghost;
  final bool? immersive;

  const PlayButton({
    super.key,
    this.size = 24,
    this.color,
    this.ghost = false,
    this.immersive = false,
  });

  void handlePressed(bool playing) {
    if (playing) {
      mediaManager.pause();
    } else {
      mediaManager.play();
    }
  }

  void handleLongPress() {
    if (immersive != true) return;

    settingsManager.setImmersive(!settingsManager.immersive.value);
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.onSurface;

    return StreamBuilder(
      stream: mediaManager.playbackState
          .map((state) => state.playing)
          .distinct(),
      builder: (context, snapshot) {
        final playing = snapshot.data ?? false;

        final button = IconButton(
          key: playing ? pauseKey : playKey,
          icon: SFIcon(
            playing ? SFIcons.sf_pause_fill : SFIcons.sf_play_fill,
            fontSize: size,
          ),
          color: iconColor,
          onPressed: () => handlePressed(playing),
          onLongPress: handleLongPress,
        );

        return RepaintBoundary(
          child: AnimatedSwitcher(
            duration: AppTheme.defaultDurationMid,
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (Widget child, Animation<double> animation) =>
                FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
            child: ghost == true
                ? button
                : Ink(
                    key: playing ? pauseKey : playKey,
                    width: size * 1.6,
                    height: size * 1.6,
                    decoration: const ShapeDecoration(
                      shape: CircleBorder(), // 圆形背景
                    ),
                    child: button,
                  ),
          ),
        );
      },
    );
  }
}
