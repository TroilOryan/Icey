import 'package:flutter_lyric/core/lyric_model.dart';
import 'package:flutter_lyric/core/lyric_parse.dart';

/// 解析标签，返回 Map，不是标签返回 null
LyricTag? _extractTag(String line) {
  final match = RegExp(r'^\[(\D*?):(.*?)\]').firstMatch(line);
  if (match == null) return null;
  return LyricTag(tag: match.group(1)!, value: match.group(2)!);
}

class LrcParser extends LyricParse {
  bool fakeEnhanced = false;
  Duration duration = Duration.zero;

  @override
  bool isMatch(String mainLyric) {
    return RegExp(
      r'^\[(\d{1,}):(\d{2})(?:\.(\d{1,}))?\]',
      multiLine: true,
    ).hasMatch(mainLyric);
  }

  @override
  LyricModel parseRaw(String mainLyric, {String? translationLyric}) {
    final Map<String, String> idTags = {};
    final List<LyricLine> lines = [];

    // 用于跟踪时间戳到 LyricLine 的映射，处理重复时间戳
    final Map timeToLyricLine = {};
    // 用于跟踪已出现的时间戳
    final Set seenTimestamps = {};

    for (var line in mainLyric.split('\n')) {
      // 提取标签内容
      final tagInfo = _extractTag(line);
      if (tagInfo != null) {
        final tag = tagInfo;
        idTags[tag.tag] = tag.value;
        continue;
      }

      // 提取时间戳和文本
      final regexp = RegExp(
        r'\[(\d{1,}):(\d{2})(?:\.(\d{1,}))?\]',
        multiLine: true,
      );
      final matches = regexp.allMatches(line);
      if (matches.isEmpty) continue;

      // 提取第一个时间作为 start
      final firstMatch = matches.first;
      final minutes = firstMatch.group(1);
      final seconds = firstMatch.group(2);
      var milliseconds = firstMatch.group(3) ?? '0';
      if (milliseconds.length > 3) {
        milliseconds = milliseconds.substring(0, 3);
      }
      final Duration start = Duration(
        minutes: int.parse(minutes!),
        seconds: int.parse(seconds!),
        milliseconds: int.parse(milliseconds.padRight(3, '0')),
      );

      // 移除所有时间戳，只保留文本
      String text = line;
      for (var match in matches) {
        text = text.replaceAll(match.group(0)!, '');
      }
      text = text.trim();

      // 检查是否为空行
      if (text.isEmpty) continue;

      // 过滤无意义的内容
      if (text == '//' || text.startsWith('//')) continue;

      final int timeMs = start.inMilliseconds;

      // 检查时间戳是否重复
      if (seenTimestamps.contains(timeMs)) {
        // 重复时间戳，当前行作为翻译
        final existingLyricLine = timeToLyricLine[timeMs]!;

        // 创建新的 LyricLine，添加翻译
        final newLyricLine = LyricLine(
          start: existingLyricLine.start,
          text: existingLyricLine.text,
          translation: text, // 直接使用整行文本，不拆分
        );

        // 更新映射和列表
        timeToLyricLine[timeMs] = newLyricLine;
        final index = lines.indexWhere(
          (l) => l.start == existingLyricLine.start,
        );
        if (index != -1) {
          lines[index] = newLyricLine;
        }
      } else {
        // 首次出现的时间戳
        seenTimestamps.add(timeMs);

        // 对于首次出现的时间戳，使用 extractLine 进行拆分
        final lyricLine = extractLine(line);
        if (lyricLine != null) {
          // 使用 extractLine 的结果
          final finalLyricLine = LyricLine(
            start: lyricLine.start,
            text: lyricLine.text,
            translation: lyricLine.translation,
            words: lyricLine.words,
          );

          timeToLyricLine[timeMs] = finalLyricLine;
          lines.add(finalLyricLine);
        }
      }
    }

    lines.sort((a, b) => a.start.compareTo(b.start));

    // 如果启用了 fakeEnhanced，对普通歌词进行逐字适配
    if (fakeEnhanced && lines.isNotEmpty) {
      for (int i = 0; i < lines.length; i++) {
        // 跳过已经有逐字信息的行（原生的逐字歌词）
        if (lines[i].words != null && lines[i].words!.isNotEmpty) {
          continue;
        }

        final Duration startTime = lines[i].start;
        final String text = lines[i].text;

        // 计算结束时间：下一行的开始时间，如果是最后一行则使用歌曲总时长
        Duration? endTime;
        if (i < lines.length - 1) {
          // 超过1.5s应该就是包含了伴奏的歌词 直接根据文本长度计算结束时间
          if (lines[i + 1].start.inMilliseconds - startTime.inMilliseconds >
              1500) {
            endTime = Duration(
              milliseconds: startTime.inMilliseconds + text.length * 100,
            );
          } else {
            endTime = Duration(
              milliseconds: lines[i + 1].start.inMilliseconds - 15,
            );
          }
        } else {
          // 最后一行，使用歌曲总时长
          endTime = duration;
        }

        // 如果没有结束时间，跳过
        if (endTime == null) continue;

        // 将整行文本拆分成逐字高亮
        final List<LyricWord> words = [];

        // 计算每个字符的时长（平均分配）
        final Duration lineDuration = endTime - startTime;
        final int charCount = text.length;
        if (charCount == 0) continue;

        final Duration charDuration = Duration(
          microseconds: lineDuration.inMicroseconds ~/ charCount,
        );

        // 为每个字符创建 LyricWord
        for (int j = 0; j < charCount; j++) {
          final Duration charStartTime = startTime + (charDuration * j);
          final Duration charEndTime = (j == charCount - 1)
              ? endTime
              : charStartTime + charDuration;

          words.add(
            LyricWord(text: text[j], start: charStartTime, end: charEndTime),
          );
        }

        // 更新当前行，添加逐字信息
        lines[i] = LyricLine(
          start: startTime,
          text: text,
          translation: lines[i].translation,
          words: words,
        );
      }
    }

    return LyricModel(lines: lines, tags: idTags);
  }

  static LyricLine? extractLine(String line) {
    final regexp = RegExp(
      r'\[(\d{1,}):(\d{2})(?:\.(\d{1,}))?\]',
      multiLine: true,
    );
    final matches = regexp.allMatches(line);
    if (matches.isEmpty) return null;

    // 提取所有时间戳
    final List<Duration> durations = [];
    for (var match in matches) {
      final minutes = match.group(1);
      final seconds = match.group(2);
      var milliseconds = match.group(3) ?? '0';
      if (milliseconds.length > 3) {
        milliseconds = milliseconds.substring(0, 3);
      }
      Duration duration = Duration(
        minutes: int.parse(minutes!),
        seconds: int.parse(seconds!),
        milliseconds: int.parse(milliseconds.padRight(3, '0')),
      );
      durations.add(duration);
    }

    // 提取第一个时间作为 start
    final Duration start = durations.first;

    // 移除所有时间戳，只保留文本
    for (var match in matches) {
      line = line.replaceAll(match.group(0)!, '');
    }

    final String mainText = line.trim();

    // 检查是否为空行或只有时间戳的行
    if (mainText.isEmpty) {
      return null;
    }

    // 过滤无意义的内容
    if (mainText == '//' || mainText.startsWith('//')) {
      return null;
    }

    // 关键修改：只有单时间戳且包含这些符号时才跳过，多时间戳（逐字歌词）不跳过
    if (durations.length == 1 &&
        (mainText.contains('/') ||
            mainText.contains(':') ||
            mainText.contains('：'))) {
      return LyricLine(
        start: start,
        text: mainText,
        translation: null,
        words: null,
      );
    }

    // 如果有多个时间戳，认为是逐字歌词
    if (durations.length > 1) {
      final List<LyricWord> words = _extractWords(mainText, durations);
      return LyricLine(
        start: start,
        text: mainText,
        translation: null,
        words: words,
      );
    }

    // 单时间戳情况，继续原有的翻译检测逻辑
    // 找到中文翻译的起始位置（只识别真正的中文字符）
    int chineseStartIndex = -1;

    for (int i = 0; i < mainText.length; i++) {
      // 跳过空格
      if (mainText[i] == ' ') {
        continue;
      }

      // 检查是否是中文字符（Unicode 范围 0x4E00-0x9FFF）
      final int charCode = mainText.codeUnitAt(i);
      if (charCode >= 0x4E00 && charCode <= 0x9FFF) {
        // 找到真正的中文字符后，检查是否是连续的中文字符
        int chineseLength = 0;
        for (int j = i; j < mainText.length; j++) {
          final int innerCharCode = mainText.codeUnitAt(j);
          // 只统计真正的中文字符
          if (innerCharCode >= 0x4E00 && innerCharCode <= 0x9FFF) {
            chineseLength++;
          } else if (mainText[j] == ' ') {
            // 允许中文中间有空格
            continue;
          } else {
            break; // 遇到非中文字符就停止
          }
        }

        // 如果有足够的连续中文字符（至少2个），认为是中文翻译的开始
        if (chineseLength >= 2) {
          chineseStartIndex = i;
          break;
        }
      }
    }

    // 如果找到了中文翻译，分割原歌词和翻译
    if (chineseStartIndex > 0) {
      final String originalLyric = mainText
          .substring(0, chineseStartIndex)
          .trim();
      final String chineseTranslation = mainText
          .substring(chineseStartIndex)
          .trim();

      return LyricLine(
        start: start,
        text: originalLyric,
        translation: chineseTranslation,
      );
    }

    return LyricLine(start: start, text: mainText);
  }

  // 提取逐字高亮信息
  static List<LyricWord> _extractWords(String text, List<Duration> durations) {
    final List<LyricWord> words = [];

    if (durations.isEmpty) {
      return words;
    }

    // 逐字逐时间戳匹配
    int textIndex = 0;

    for (int i = 0; i < durations.length && textIndex < text.length; i++) {
      final Duration startTime = durations[i];
      Duration? endTime;

      // 计算结束时间
      if (i < durations.length - 1) {
        endTime = durations[i + 1];
      }

      // 获取当前字符
      final String char = text[textIndex];
      textIndex++;

      // 如果当前字符是空格，跳过空格，将时间分配给下一个非空格字符
      if (char == ' ') {
        // 继续查找下一个非空格字符
        while (textIndex < text.length && text[textIndex] == ' ') {
          textIndex++;
        }

        // 如果找到了非空格字符，将时间分配给这个字符
        if (textIndex < text.length) {
          final String nextChar = text[textIndex];
          textIndex++;

          words.add(LyricWord(text: nextChar, start: startTime, end: endTime));
        } else {
          // 没有找到非空格字符，添加空字符串
          words.add(LyricWord(text: '', start: startTime, end: endTime));
        }
      } else {
        // 非空格字符，直接添加
        words.add(LyricWord(text: char, start: startTime, end: endTime));
      }
    }

    // 如果还有剩余的文本（时间戳少于字符），添加到最后一个 LyricWord
    if (textIndex < text.length && words.isNotEmpty) {
      final String remainingText = text.substring(textIndex);
      final lastWord = words.last;
      words.last = LyricWord(
        text: lastWord.text + remainingText,
        start: lastWord.start,
        end: lastWord.end,
      );
    }

    return words;
  }
}
