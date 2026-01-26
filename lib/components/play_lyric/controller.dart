import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:signals/signals.dart';

import 'lyric_parser/lyric_parser.dart';

class PlayLyricController {
  final lyricController = LyricController();

  final lyricParser = LyricParser();

  late final EffectCleanup lyricListener;

  late final EffectCleanup progressListener;

  bool isHighlight(bool karaoke, bool fakeEnhanced, bool? isEnhanced) {
    if (karaoke && isEnhanced == true) {
      return true;
    } else if (!karaoke) {
      return false;
    } else if (fakeEnhanced) {
      return true;
    } else {
      return isEnhanced ?? false;
    }
  }

  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lyricListener = effect(() {
        final lyricModel = lyricParser.parseRaw(mediaManager.rawLyric.value);

        mediaManager.setParsedLyric(lyricModel.lines);

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
