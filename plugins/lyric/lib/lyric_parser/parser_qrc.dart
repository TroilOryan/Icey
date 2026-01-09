import 'package:lyric/lyric_parser/lyrics_parse.dart';
import 'package:lyric/lyrics_log.dart';
import 'package:lyric/lyrics_reader_model.dart';

///qrc lyric parser
class ParserQrc extends LyricsParse {
  ParserQrc(String lyric) : super(lyric);

  final RegExp advancedPattern = RegExp(r"""\[\d+,\d+]""");

  final RegExp qrcPattern = RegExp(r"""\((\d+,\d+)\)""");

  final RegExp advancedValuePattern = RegExp(r"\[(\d*,\d*)\]");

  @override
  List<LyricsLineModel> parseLines({bool isMain = true}) {
    lyric =
        RegExp(r"""LyricContent="([\s\S]*)">""").firstMatch(lyric)?.group(1) ??
            lyric;

    //读每一行
    List<String> lines = lyric.split("\n");

    if (lines.isEmpty) {
      LyricsLog.logD("未解析到歌词");
      return [];
    }

    List<LyricsLineModel> lineList = [];

    for (String line in lines) {
      //匹配time
      String? time = advancedPattern.stringMatch(line);

      if (time == null) {
        //没有匹配到直接返回
        //TODO 歌曲相关信息暂不处理
        LyricsLog.logD("忽略未匹配到Time：$line");
        continue;
      }

      //转时间戳
      int? ts = int.parse(
          advancedValuePattern.firstMatch(time)?.group(1)?.split(",")[0] ??
              "0");

      //移除time，拿到真实歌词
      String realLyrics = line.replaceFirst(advancedPattern, "");

      if (realLyrics.isEmpty) {
        continue;
      }

      LyricsLog.logD("匹配time:$time($ts) 真实歌词：$realLyrics");

      List<LyricSpanInfo> spanList = getSpanList(realLyrics);

      LyricsLineModel lineModel = LyricsLineModel()
        ..mainText = realLyrics.replaceAll(qrcPattern, "")
        ..startTime = ts
        ..spanList = spanList;

      lineList.add(lineModel);
    }

    return lineList;
  }

  ///get line span info list
  List<LyricSpanInfo> getSpanList(String realLyrics) {
    int invalidLength = 0;
    int startIndex = 0;
    List<LyricSpanInfo> spanList =
        qrcPattern.allMatches(realLyrics).map((element) {
      LyricSpanInfo span = LyricSpanInfo();

      span.raw =
          realLyrics.substring(startIndex + invalidLength, element.start);

      String elementText = element.group(0) ?? "";
      span.index = startIndex;
      span.length = element.start - span.index - invalidLength;
      invalidLength += elementText.length;
      startIndex += span.length;

      List<String> time = (element.group(1)?.split(",") ?? ["0", "0"]);
      span.start = int.parse(time[0]);
      span.duration = int.parse(time[1]);

      return span;
    }).toList();

    return spanList;
  }

  @override
  bool isValid() {
    return lyric.contains("LyricContent=") ||
        advancedPattern.stringMatch(lyric) != null;
  }
}
