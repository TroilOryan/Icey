import 'dart:async';

import 'package:IceyPlayer/components/play_screen/landscape/landscape.dart';
import 'package:IceyPlayer/components/play_screen/play_screen_background.dart';
import 'package:IceyPlayer/components/play_screen/portrait/portrait.dart';
import 'package:IceyPlayer/components/play_screen/state.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

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
    mediaItemListener = mediaManager.mediaItem.listen((mediaItem) {
      if (currentMediaItem != mediaItem) {
        rotationController?.reverse();
        currentMediaItem = mediaItem;
      }
    });

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
  }

  void onDispose() {
    rotationController?.stop();

    mediaItemListener.cancel();

    playbackStateListener.cancel();
  }
}
