import 'package:IceyPlayer/components/marquee/marquee.dart';
import 'package:IceyPlayer/constants/settings.dart';
import 'package:IceyPlayer/helpers/overlay/overlay.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

part 'state.dart';

part 'play_lyric_overlay.dart';

class PlayLyricOverlayController {
  final state = PlayLyricOverlayState();

  void onInit() {
    OverlayHelper.overlayListener?.listen((event) {
      if (event?["lyric"] != null) {
        state.lyric.value = event["lyric"]["text"];
        state.duration.value = event["lyric"]["duration"];
      }

      if (event?["fontSize"] != null) {
        state.fontSize.value = event["fontSize"].toDouble();
      }

      if (event?["width"] != null) {
        state.width.value = event["width"].toDouble();
      }

      if (event?["color"] != null) {
        state.color.value = Color(event["color"]);
      }

      if (event?["playing"] != null) {
        state.playing.value = event["playing"];
      }

      if (event?["visible"] != null) {
        state.visible.value = event["visible"];
      }
    });
  }

  void onDispose() {
    OverlayHelper.disposeOverlayListener();
  }
}
