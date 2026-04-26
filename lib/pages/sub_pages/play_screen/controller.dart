import 'dart:async';

import 'package:IceyPlayer/components/adaptive_builder/adaptive_builder.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/pages/sub_pages/play_screen/concert/concert.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'landscape/landscape.dart';
import 'play_screen_background/play_screen_background.dart';
import 'portrait/portrait.dart';
import 'tablet/tablet.dart';

part 'state.dart';

part 'page.dart';

class PlayScreenController {
  TickerProvider? vsync;

  final state = PlayScreenState();

  AnimationController? rotationController;

  late StreamSubscription<MediaItem?> mediaItemListener;

  late StreamSubscription<bool> playbackStateListener;

  MediaItem? currentMediaItem;

  void handleOpenLyric(BuildContext context) {
    if (settingsManager.immersive.value) return;

    state.offset.value = state.lyricOpened.value
        ? 0
        : MediaQuery.of(context).size.width;

    state.lyricOpened.value = !state.lyricOpened.value;
  }

  void handlePopInvokedWithResult(bool didPop, dynamic result) {
    if (didPop) return;

    if (state.lyricOpened.value) {
      state.lyricOpened.value = false;
      state.offset.value = 0;

      return;
    }
  }

  void updateVsync(TickerProvider newVsync) {
    if (rotationController != null && rotationController!.isAnimating) {
      rotationController!.stop();
    }
    vsync = newVsync;
    if (rotationController != null &&
        rotationController!.status == AnimationStatus.forward) {
      rotationController!.forward(from: rotationController!.value);
    }
  }

  void onInit() {
    // 重新订阅媒体项变化
    mediaItemListener = mediaManager.mediaItem.listen((mediaItem) {
      if (currentMediaItem != mediaItem) {
        rotationController?.reverse();
        currentMediaItem = mediaItem;
      }
    });

    // 重新订阅播放状态变化
    playbackStateListener = mediaManager.playbackState
        .map((state) => state.playing)
        .listen((playing) {
          if (playing == true && rotationController?.isAnimating == false) {
            rotationController?.repeat();
          } else if (playing == false &&
              rotationController?.isAnimating == true) {
            rotationController?.stop();
          }
        });

    // 根据当前播放状态恢复动画
    if (mediaManager.playbackState.value.playing &&
        rotationController != null &&
        !rotationController!.isAnimating) {
      rotationController?.repeat();
    }
  }

  void onDispose() {
    // 取消流订阅
    mediaItemListener.cancel();
    playbackStateListener.cancel();

    // 只停止动画，不 dispose，保持状态
    rotationController?.stop();
  }
}
