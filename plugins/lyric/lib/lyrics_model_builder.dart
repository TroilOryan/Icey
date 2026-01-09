import 'package:lyric/lyric_parser/lyrics_parse.dart';
import 'package:lyric/lyrics_reader.dart';

import 'lyric_parser/parser_smart.dart';
import 'lyrics_reader_model.dart';
import 'package:collection/collection.dart';

/// lyric Util
/// support Simple format、Enhanced format
class LyricsModelBuilder {
  ///if line time is null,then use MAX_VALUE replace
  static final defaultLineDuration = 5000;

  List<LyricsLineModel>? mainLines;

  List<LyricsLineModel>? extLines;

  LyricsReaderModel _lyricModel = LyricsReaderModel();

  void reset() {
    _lyricModel = LyricsReaderModel();
  }

  static LyricsModelBuilder create() => LyricsModelBuilder._();

  LyricsModelBuilder bindLyricToMain(String lyric, [LyricsParse? parser]) {
    mainLines = (parser ?? ParserSmart(lyric)).parseLines();

    return this;
  }

  LyricsModelBuilder bindLyricToExt(String lyric, [LyricsParse? parser]) {
    extLines = (parser ?? ParserSmart(lyric)).parseLines(isMain: false);

    return this;
  }

  void _setLyric(List<LyricsLineModel>? lineList,
      {isMain = true, fakeEnhanced = false}) {
    if (lineList == null) return;

    // 对于本身非逐字的歌词 强行逐字
    // 下一行的开始时间则为上一行的结束时间，若无则MAX
    if (lineList
            .every((e) => e.spanList?.isEmpty == null || e.spanList!.isEmpty) &&
        fakeEnhanced) {
      for (int i = 0; i < lineList.length; i++) {
        LyricsLineModel currLine = lineList[i];
        try {
          currLine.endTime = lineList[i + 1].startTime;
        } catch (e) {
          LyricSpanInfo? lastSpan = currLine.spanList?.lastOrNull;

          if (lastSpan != null) {
            currLine.endTime = lastSpan.end;
          } else {
            currLine.endTime = (currLine.startTime ?? 0) + defaultLineDuration;
          }
        }
      }
    }

    if (isMain) {
      _lyricModel.lyrics.clear();
      _lyricModel.lyrics.addAll(lineList);
    } else {
      //扩展歌词对应行
      for (LyricsLineModel mainLine in _lyricModel.lyrics) {
        LyricsLineModel extLine = lineList.firstWhere(
            (extLine) =>
                mainLine.startTime == extLine.startTime &&
                mainLine.endTime == extLine.endTime, orElse: () {
          return LyricsLineModel();
        });

        mainLine.extText = extLine.extText;
      }
    }
  }

  LyricsReaderModel getModel({bool? fakeEnhanced}) {
    _setLyric(mainLines, isMain: true, fakeEnhanced: fakeEnhanced);

    _setLyric(extLines, isMain: false, fakeEnhanced: fakeEnhanced);

    return _lyricModel;
  }

  LyricsModelBuilder._();
}
