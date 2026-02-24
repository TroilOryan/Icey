import 'package:IceyPlayer/components/play_lyric_source/play_lyric_source.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/constants/cache_key.dart';
import 'package:IceyPlayer/helpers/common.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:flutter_lyric/core/lyric_model.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:signals/signals_flutter.dart';

import 'lyric_parser/lyric_parser.dart';

final lyricManager = LyricManager();

final _settingsBox = Boxes.settingsBox;

class LyricManager {
  late final EffectCleanup lyricListener;

  late final EffectCleanup lyricDurationListener;

  final lyricParser = LyricParser();

  final Signal<LyricModel?> _lyricModel;

  final Signal<String> _rawLyric;

  final Signal<List<LyricLine>> _parsedLyric;

  final Signal<LyricSource> _lyricSource;

  final Signal<int> _currentIndex;

  final Signal<double> _overlayLyricSize;

  final Signal<double> _overlayLyricWidth;

  final Signal<int> _overlayLyricColor;

  final Signal<double> _overlayLyricX;

  final Signal<double> _overlayLyricY;

  Signal<LyricModel?> get lyricModel => _lyricModel;

  // 歌词源数据
  Signal<String> get rawLyric => _rawLyric;

  // 解析后的歌词
  Signal<List<LyricLine>> get parsedLyric => _parsedLyric;

  // 歌词数据来源
  Signal<LyricSource> get lyricSource => _lyricSource;

  Signal<int> get currentIndex => _currentIndex;

  Signal<double> get overlayLyricSize => _overlayLyricSize;

  Signal<double> get overlayLyricWidth => _overlayLyricWidth;

  Signal<int> get overlayLyricColor => _overlayLyricColor;

  Signal<double> get overlayLyricX => _overlayLyricX;

  Signal<double> get overlayLyricY => _overlayLyricY;

  LyricManager()
    : _lyricModel = signal(null),
      _rawLyric = signal(""),
      _parsedLyric = signal([]),
      _lyricSource = signal(LyricSource.none),
      _currentIndex = signal(-1),
      _overlayLyricSize = signal(16.0),
      _overlayLyricWidth = signal(100.0),
      _overlayLyricColor = signal(0),
      _overlayLyricX = signal(0.0),
      _overlayLyricY = signal(0.0) {
    setOverlayLyricSize(
      _settingsBox.get(CacheKey.Settings.overlayLyricSize, defaultValue: 16.0),
    );

    setOverlayLyricWidth(
      _settingsBox.get(
        CacheKey.Settings.overlayLyricWidth,
        defaultValue: 100.0,
      ),
    );

    setOverlayLyricColor(
      _settingsBox.get(CacheKey.Settings.overlayLyricColor, defaultValue: 0),
    );

    setOverlayLyricX(
      _settingsBox.get(CacheKey.Settings.overlayLyricX, defaultValue: 0.0),
    );

    setOverlayLyricY(
      _settingsBox.get(CacheKey.Settings.overlayLyricY, defaultValue: 0.0),
    );

    lyricListener = effect(() {
      batch(() {
        lyricParser.karaoke = settingsManager.karaoke.value;
        lyricParser.fakeEnhanced = settingsManager.fakeEnhanced.value;

        final model = lyricParser.parseRaw(_rawLyric.value);

        _lyricModel.value = model;
      });
    });

    lyricDurationListener = effect(() {
      lyricParser.duration =
          mediaManager.currentMediaItem.value?.duration ?? Duration.zero;
    });
  }

  void dispose() {
    lyricListener();
  }

  void setLyricModel(String value) {
    _rawLyric.value = value;

    final model = lyricParser.parseRaw(value);

    _lyricModel.value = model;

    final lyric = model.lines;

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
        setCurrentIndex(index);
      }
    } else {
      setCurrentIndex(-1);
    }
  }

  void setCurrentIndexByPosition(Duration position) {
    setCurrentIndexByLyric(_parsedLyric.value, position);
  }

  void setCurrentIndex(int value) {
    _currentIndex.value = value;

    FlutterOverlayWindow.shareData({"lyric": _parsedLyric.value[value].text});
  }

  void setOverlayLyricSize(double value) {
    _overlayLyricSize.value = value;

    _settingsBox.put(CacheKey.Settings.overlayLyricSize, value);

    FlutterOverlayWindow.shareData({"fontSize": value});
  }

  void setOverlayLyricWidth(double value) {
    _overlayLyricWidth.value = value;

    _settingsBox.put(CacheKey.Settings.overlayLyricWidth, value);

    FlutterOverlayWindow.shareData({"width": value});
  }

  void setOverlayLyricColor(int value) {
    _overlayLyricColor.value = value;

    _settingsBox.put(CacheKey.Settings.overlayLyricColor, value);

    FlutterOverlayWindow.shareData({"color": value});
  }

  void setOverlayLyricX(double value) {
    _overlayLyricX.value = value;

    _settingsBox.put(CacheKey.Settings.overlayLyricX, value);

    FlutterOverlayWindow.moveOverlay(
      OverlayPosition(value, _overlayLyricY.value),
    );
  }

  void setOverlayLyricY(double value) {
    _overlayLyricY.value = value;

    _settingsBox.put(CacheKey.Settings.overlayLyricY, value);

    FlutterOverlayWindow.moveOverlay(
      OverlayPosition(_overlayLyricX.value, value),
    );
  }
}
