import 'package:IceyPlayer/components/play_lyric_source/play_lyric_source.dart';
import 'package:IceyPlayer/helpers/common.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:flutter_lyric/core/lyric_model.dart';
import 'package:signals/signals_flutter.dart';

import 'lyric_parser/lyric_parser.dart';

final lyricManager = LyricManager();

class LyricManager {
  late final EffectCleanup lyricListener;

  final lyricParser = LyricParser();

  LyricModel? lyricModel;

  final Signal<String> _rawLyric;

  final Signal<List<LyricLine>> _parsedLyric;

  final Signal<LyricSource> _lyricSource;

  final Signal<int> _currentIndex;

  // 歌词源数据
  Signal<String> get rawLyric => _rawLyric;

  // 解析后的歌词
  Signal<List<LyricLine>> get parsedLyric => _parsedLyric;

  // 歌词数据来源
  Signal<LyricSource> get lyricSource => _lyricSource;

  Signal<int> get currentIndex => _currentIndex;

  LyricManager()
    : _rawLyric = signal(""),
      _parsedLyric = signal([]),
      _lyricSource = signal(LyricSource.none),
      _currentIndex = signal(-1) {
    lyricListener = effect(() {
      lyricParser.fakeEnhanced = settingsManager.fakeEnhanced.value;
      lyricParser.duration =
          mediaManager.currentMediaItem.value?.duration ?? Duration.zero;
    });
  }

  void dispose() {
    lyricListener();
  }

  void setLyricModel(String value) {
    _rawLyric.value = value;

    lyricModel = lyricParser.parseRaw(value);

    final lyric = lyricModel?.lines ?? [];

    _parsedLyric.value = lyric;

    setCurrentIndexByLyric(lyric, Duration.zero);
  }

  void setLyricSource(LyricSource value) {
    _lyricSource.value = value;
  }

  void setCurrentIndexByLyric(List<LyricLine> lyric, Duration position) {
    if (lyric.isNotEmpty) {
      final index = CommonHelper.findClosestIndex(
        parsedLyric.map((e) => BigInt.from(e.start.inMilliseconds)).toList(),
        BigInt.from(position.inMilliseconds),
      );

      if (index != -1 && index != currentIndex.value) {
        currentIndex.value = index;
      }
    } else {
      currentIndex.value = -1;
    }
  }

  void setCurrentIndexByPosition(Duration position) {
    setCurrentIndexByLyric(_parsedLyric.value, position);
  }

  void setCurrentIndex(int value) {
    _currentIndex.value = value;
  }
}
