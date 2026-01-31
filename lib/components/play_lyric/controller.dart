import 'package:IceyPlayer/models/lyric/lyric.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:signals/signals_flutter.dart';

class PlayLyricController {
  final lyricController = LyricController();

  final isHighlight = signal(false);

  late final EffectCleanup blurListener;

  late final EffectCleanup lyricListener;

  late final EffectCleanup progressListener;

  void onInit({VoidCallback? onScroll}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      blurListener = effect(() {
        lyricController.setBlur(settingsManager.highMaterial.value);
      });

      lyricListener = effect(() {
        if (lyricManager.lyricModel.value != null) {
          isHighlight.value = lyricManager.lyricModel.value!.lines.any(
            (e) => e.words != null && e.words!.isNotEmpty,
          );

          lyricController
            ..loadLyric(lyricManager.rawLyric.value)
            ..loadLyricModel(lyricManager.lyricModel.value!);
        }
      });

      progressListener = effect(() {
        lyricController.setProgress(mediaManager.position.value);
      });

      lyricController.setOnTapLineCallback((Duration position) {
        mediaManager.seek(position);
      });

      if (onScroll != null) {
        lyricController.registerEvent(LyricEvent.scroll, (v) {
          lyricController.setBlur(false);

          onScroll();
        });

        lyricController.registerEvent(LyricEvent.resumeSelectedLine, (v) {
          lyricController.setBlur(settingsManager.highMaterial.value);
        });

        lyricController.registerEvent(LyricEvent.resumeActiveLine, (v) {
          lyricController.setBlur(settingsManager.highMaterial.value);
        });
      }
    });
  }

  void onDispose() {
    blurListener();
    lyricListener();
    progressListener();
  }
}
