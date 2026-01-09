import 'package:lyric/lyric_parser/lyrics_parse.dart';
import 'package:lyric/lyric_parser/parser_enhanced.dart';
import 'package:lyric/lyric_parser/parser_lrc.dart';
import 'package:lyric/lyric_parser/parser_qrc.dart';
import 'package:lyric/lyric_parser/parser_ttml.dart';
import 'package:lyric/lyrics_reader_model.dart';

import '../lyrics_log.dart';

/// smart parser
/// Parser is automatically selected
class ParserSmart extends LyricsParse {
  ParserSmart(String lyric) : super(lyric);

  @override
  List<LyricsLineModel> parseLines({bool isMain = true}) {
    final ParserQrc qrc = ParserQrc(lyric);
    final ParserEnhanced enhancedLrc = ParserEnhanced(lyric);
    final ParserLrc lrc = ParserLrc(lyric);
    final ParserTtml ttml = ParserTtml(lyric);

    if (qrc.isValid()) {
      return qrc.parseLines(isMain: isMain);
    } else if (enhancedLrc.isValid()) {
      return enhancedLrc.parseLines(isMain: isMain);
    } else if (ttml.isValid()) {
      return ttml.parseLines(isMain: isMain);
    } else if (lrc.isValid()) {
      return lrc.parseLines(isMain: isMain);
    }

    return [];
  }
}
