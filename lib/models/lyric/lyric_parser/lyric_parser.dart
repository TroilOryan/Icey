import 'package:IceyPlayer/models/lyric/lyric_parser/ttml_parser.dart';
import 'package:flutter_lyric/core/lyric_model.dart';
import 'package:flutter_lyric/core/lyric_parse.dart' hide LrcParser;

import 'lrc_parser.dart';

class LyricParser extends LyricParse {
  bool fakeEnhanced = false;
  Duration duration = Duration.zero;

  final lrcParser = LrcParser();

  final ttmlParser = TtmlParser();

  final qrcParser = QrcParser();

  @override
  bool isMatch(String mainLyric) {
    final isLrc = lrcParser.isMatch(mainLyric);

    final isQrc = qrcParser.isMatch(mainLyric);

    final isTtml = ttmlParser.isMatch(mainLyric);

    return isLrc || isTtml || isQrc;
  }

  @override
  LyricModel parseRaw(String mainLyric, {String? translationLyric}) {
    lrcParser.fakeEnhanced = fakeEnhanced;

    final isLrc = lrcParser.isMatch(mainLyric);

    final isTtml = ttmlParser.isMatch(mainLyric);

    final isQrc = qrcParser.isMatch(mainLyric);

    if (isLrc) {
      return lrcParser.parseRaw(mainLyric, translationLyric: translationLyric);
    } else if (isTtml) {
      return ttmlParser.parseRaw(mainLyric, translationLyric: translationLyric);
    } else if (isQrc) {
      return qrcParser.parseRaw(mainLyric, translationLyric: translationLyric);
    }

    return LyricModel(lines: []);
  }
}
