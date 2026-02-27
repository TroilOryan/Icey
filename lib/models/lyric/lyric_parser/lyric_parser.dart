import 'package:IceyPlayer/models/lyric/lyric_parser/ttml_parser.dart';
import 'package:IceyPlayer/src/rust/api/lyric_parser.dart';
import 'package:flutter_lyric/core/lyric_model.dart';
import 'package:flutter_lyric/core/lyric_parse.dart' hide LrcParser;

import 'lrc_parser.dart';

class LyricParser extends LyricParse {
  bool fakeEnhanced = false;

  bool karaoke = true;

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

  // Future<LyricModel> parse(String lyric) async {
  //   ParseResult? res;
  //
  //   lrcParser.fakeEnhanced = fakeEnhanced;
  //
  //   lrcParser.karaoke = karaoke;
  //
  //   lrcParser.duration = duration;
  //
  //   final isLrc = lrcParser.isMatch(lyric);
  //
  //   final isTtml = ttmlParser.isMatch(lyric);
  //
  //   final isQrc = qrcParser.isMatch(lyric);
  //
  //   if (isLrc) {
  //     res = await parseLrc(lyricContent: lyric);
  //   } else if (isTtml) {
  //     res = await parseTtml(lyricContent: lyric);
  //   } else if (isQrc) {
  //     res = await parseQrc(lyricContent: lyric);
  //   }
  //
  //   if (res == null) {
  //     return LyricModel(lines: []);
  //   }
  //
  //   return LyricModel(
  //     lines: res.lines
  //         .map(
  //           (e) => LyricLine(
  //             start: Duration(milliseconds: e.start.toInt()),
  //             end: Duration(milliseconds: e.end.toInt()),
  //             text: e.text,
  //             words: e.words
  //                 .map(
  //                   (word) => LyricWord(
  //                     text: word.text,
  //                     start: Duration(milliseconds: word.start.toInt()),
  //                     end: Duration(milliseconds: word.end.toInt()),
  //                   ),
  //                 )
  //                 .toList(),
  //             translation: e.translation,
  //           ),
  //         )
  //         .toList(),
  //   );
  // }

  @override
  LyricModel parseRaw(String mainLyric, {String? translationLyric}) {
    lrcParser.fakeEnhanced = fakeEnhanced;

    lrcParser.karaoke = karaoke;

    lrcParser.duration = duration;

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
