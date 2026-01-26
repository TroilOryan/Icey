import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:signals/signals_flutter.dart';

import 'lyric_parser/lyric_parser.dart';

class PlayLyricController {
  final lyricController = LyricController();

  final lyricParser = LyricParser();

  final isHighlight = signal(false);

  late final EffectCleanup lyricListener;

  late final EffectCleanup progressListener;

  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lyricListener = effect(() {
        lyricParser.fakeEnhanced = settingsManager.fakeEnhanced.value;
        lyricParser.duration =
            mediaManager.currentMediaItem.value?.duration ?? Duration.zero;

        final lyricModel = lyricParser.parseRaw(mediaManager.rawLyric.value);

        mediaManager.setParsedLyric(lyricModel.lines);

        isHighlight.value = lyricModel.lines.any(
          (e) => e.words != null && e.words!.isNotEmpty,
        );

        lyricController
          ..loadLyric(mediaManager.rawLyric.value)
          ..loadLyricModel(lyricModel);
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
