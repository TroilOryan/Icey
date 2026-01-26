import 'package:flutter_lyric/core/lyric_model.dart';
import 'package:flutter_lyric/core/lyric_parse.dart' hide LrcParser;

import 'lrc_parser.dart';

class LyricParser extends LyricParse {
  bool fakeEnhanced = false;
  Duration duration = Duration.zero;

  @override
  bool isMatch(String mainLyric) {
    final lrcParser = LrcParser();

    final qrcParser = QrcParser();

    final isLrc = lrcParser.isMatch(mainLyric);

    final isQrc = qrcParser.isMatch(mainLyric);

    return isLrc || isQrc;
  }

  @override
  LyricModel parseRaw(String mainLyric, {String? translationLyric}) {
    final lrcParser = LrcParser();

    final qrcParser = QrcParser();

    lrcParser.fakeEnhanced = fakeEnhanced;

    final isLrc = lrcParser.isMatch(mainLyric);

    final isQrc = qrcParser.isMatch(mainLyric);

    if (isLrc) {
      return lrcParser.parseRaw(mainLyric, translationLyric: translationLyric);
    } else if (isQrc) {
      return qrcParser.parseRaw(mainLyric, translationLyric: translationLyric);
    }

    return LyricModel(lines: []);
  }
}
