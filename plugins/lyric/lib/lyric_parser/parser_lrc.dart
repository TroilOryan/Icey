import 'dart:collection';

import 'package:lyric/lyric_parser/language_auto_splitter.dart';
import 'package:lyric/lyric_parser/lyrics_parse.dart';
import 'package:lyric/lyrics_log.dart';
import 'package:lyric/lyrics_reader_model.dart';

/// 支持多语言翻译的歌词解析器
class ParserLrc extends LyricsParse {
  final RegExp advancedPattern = RegExp(r"\[(\d{2}:\d{1,2}\.\d{2,3})\]");
  RegExp pattern = RegExp(r"\[\d{2}:\d{2}\.\d{2,3}]");
  RegExp valuePattern = RegExp(r"\[(\d{2}:\d{1,2}\.\d{2,3})\]");

  ParserLrc(String lyric) : super(lyric);

  @override
  List<LyricsLineModel> parseLines({bool isMain = true}) {
    final filteredLyric = filterMetadataLines(lyric);
    final lines = filteredLyric.split("\n");
    if (lines.isEmpty) return [];

    // 使用LinkedHashMap保留插入顺序，确保原歌词先出现
    final LinkedHashMap<String, LyricsLineModel> timestampMap = LinkedHashMap();

    for (String line in lines) {
      // 提取时间戳
      String? time = pattern.stringMatch(line);
      if (time == null) continue;

      // 提取真实歌词内容
      String realLyrics = line.replaceFirst(pattern, "").trim();

      // 过滤空行和注释行
      if (realLyrics.isEmpty || realLyrics == "//") {
        LyricsLog.logD("过滤空歌词行: $time");
        continue;
      }

      // 解析时间戳为毫秒数
      int? ts = timeTagToTS(time);

      if (ts == null) continue;

      final res = LanguageAutoSplitter.splitMixedText(realLyrics);

      // 处理歌词行（相同时间戳合并为原歌词+翻译）
      if (timestampMap.containsKey(time)) {
        // 已存在相同时间戳，作为翻译文本
        timestampMap[time]!.extText = realLyrics;
      } else {
        // 新时间戳，作为原歌词文本
        timestampMap[time] = LyricsLineModel()
          ..startTime = ts
          ..mainText = realLyrics
          ..extText = "";
      }

      if (res["extText"] != null && (res["extText"]?.length ?? 0) > 0) {
        timestampMap[time] = LyricsLineModel()
          ..startTime = ts
          ..mainText = res["mainText"]
          ..extText = res["extText"];
      }
    }

    return timestampMap.values.toList();
  }

  int? timeTagToTS(String timeTag) {
    if (timeTag.trim().isEmpty) {
      LyricsLog.logW("时间标签为空");
      return null;
    }

    // 提取时间值（支持中括号/尖括号包裹）
    final timeMatch = RegExp(r'[\[<](\d+:\d+\.\d+)[\]>]').firstMatch(timeTag);
    if (timeMatch == null) {
      LyricsLog.logW("未匹配到时间值：$timeTag");
      return null;
    }

    final value = timeMatch.group(1)!;
    try {
      final timeParts = value.split(RegExp(r'[:.]'));
      if (timeParts.length != 3) {
        LyricsLog.logW("时间格式无效: $value");
        return null;
      }

      // 补全各部分位数
      final minutes = int.parse(timeParts[0].padLeft(2, '0'));
      final seconds = int.parse(timeParts[1].padLeft(2, '0'));
      final milliseconds =
          int.parse(timeParts[2].padRight(3, '0').substring(0, 3));

      return Duration(
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds,
      ).inMilliseconds;
    } catch (e) {
      LyricsLog.logD("时间解析失败: $value，错误: $e");
      return null;
    }
  }

  @override
  bool isValid() {
    return advancedPattern.hasMatch(lyric);
  }
}
