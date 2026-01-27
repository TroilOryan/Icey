import 'package:IceyPlayer/models/lyric/lyric.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:signals/signals_flutter.dart';

class PlayLyricController {
  final lyricController = LyricController();

  final isHighlight = signal(false);

  late final EffectCleanup lyricListener;

  late final EffectCleanup progressListener;

  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lyricListener = effect(() {
        if (lyricManager.lyricModel != null) {
          isHighlight.value = lyricManager.lyricModel!.lines.any(
            (e) => e.words != null && e.words!.isNotEmpty,
          );

          lyricController
            ..loadLyric(lyricManager.rawLyric.value)
            ..loadLyricModel(lyricManager.lyricModel!);
        }
      });

      progressListener = effect(() {
        lyricController.setProgress(mediaManager.position.value);
      });

      lyricController.setOnTapLineCallback((Duration position) {
        mediaManager.seek(position);
      });
    });
  }

  void onDispose() {
    lyricListener();
    progressListener();
  }
}
