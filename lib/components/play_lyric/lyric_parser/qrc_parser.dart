import 'package:flutter_lyric/core/lyric_model.dart';
import 'package:flutter_lyric/core/lyric_parse.dart';

/// 解析标签，返回 Map，不是标签返回 null
LyricTag? _extractTag(String line) {
  final match = RegExp(r'^\[(\D*?):(.*?)\]').firstMatch(line);
  if (match == null) return null;
  return LyricTag(tag: match.group(1)!, value: match.group(2)!);
}

class QrcParser extends LyricParse {
  @override
  bool isMatch(String mainLyric) {
    return RegExp(
      r'^\[\d{1,},(\d{1,})?\]',
      multiLine: true,
    ).hasMatch(mainLyric);
  }

  @override
  LyricModel parseRaw(String mainLyric, {String? translationLyric}) {
    final idTags = <String, String>{};
    final match = RegExp(r'LyricContent=([\s\S]*)"\/>').firstMatch(mainLyric);

    // 提取翻译歌词
    var translationMap = LrcParser.extractTranslationMap(translationLyric);

    final lyricContent = match?.group(1) ?? mainLyric;
    final lineRegExp = RegExp(r'(\[\d+,\d+\])?(.*?)(\(\d+,\d+\))');
    final lines = <LyricLine>[];
    for (var line in lyricContent.split('\n')) {
      // 提取标签内容
      final tagInfo = _extractTag(line);
      if (tagInfo != null) {
        final tag = tagInfo;
        idTags[tag.tag] = tag.value;
        continue;
      }
      Duration startTime = Duration.zero;
      Duration endTime = Duration.zero;
      String text = '';
      final matchs = lineRegExp.allMatches(line);
      if (matchs.isEmpty) continue;
      final words = <LyricWord>[];
      for (var match in matchs) {
        final totalTime = match.group(1);
        if (totalTime?.isNotEmpty ?? false) {
          final time = extractTime(totalTime!);
          startTime = time.first;
          endTime = time.first + time.second;
        }
        final wordText = match.group(2) ?? '';
        text += wordText;

        final time = extractTime(match.group(3)!);
        words.add(LyricWord(
            text: wordText, start: time.first, end: time.first + time.second));
      }
      LyricLine lyricLine = LyricLine(
        start: startTime,
        end: endTime,
        text: text,
        words: words,
        translation: LrcParser.findTranslation(
            translationMap, startTime.inMilliseconds, 10),
      );
      lines.add(lyricLine);
    }
    return LyricModel(lines: lines, tags: idTags);
  }

  Pair<Duration, Duration> extractTime(String time) {
    final timeRegExp = RegExp(r'.(\d+),(\d+).');
    final timeMatch = timeRegExp.firstMatch(time);
    final start = timeMatch!.group(1)!;
    final duration = timeMatch.group(2)!;
    return Pair(
        first: Duration(milliseconds: int.parse(start)),
        second: Duration(milliseconds: int.parse(duration)));
  }
}
