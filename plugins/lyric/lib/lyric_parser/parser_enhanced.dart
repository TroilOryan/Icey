import 'dart:collection';

import '../lyrics_log.dart';
import '../lyrics_reader_model.dart';
import 'language_auto_splitter.dart';
import 'lyrics_parse.dart';

class ParserEnhanced extends LyricsParse {
  ParserEnhanced(String lyric) : super(lyric);

  // 中括号时间戳匹配（支持00:00.000格式）
  final RegExp valuePattern = RegExp(r"\[(\d{2}:\d{1,2}\.\d{2,3})\]");

  // 尖括号时间戳匹配
  final RegExp angleValuePattern = RegExp(r'\s*<(\d{2}:\d{1,2}\.\d{2,3})>\s*');

  // 角色信息提取
  final RegExp rolePattern = RegExp(r'^(\w+):\s*');

  @override
  List<LyricsLineModel> parseLines({bool isMain = true}) {
    final filteredLyric = filterMetadataLines(lyric)
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
    final lines = filteredLyric.split("\n");

    if (lines.isEmpty) {
      LyricsLog.logD("未解析到歌词");
      return [];
    }

    // 使用LinkedHashMap缓存时间戳与歌词模型，保留插入顺序
    final LinkedHashMap<String, _LineCache> timestampCache = LinkedHashMap();

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      // 判断格式类型
      final hasBracket = valuePattern.hasMatch(line);
      final hasAngle = angleValuePattern.hasMatch(line);
      final isMixedFormat = hasBracket && hasAngle;

      final bracketMatches = valuePattern.allMatches(line);
      final angleMatches = angleValuePattern.allMatches(line);
      final isBracketMultiFormat = !isMixedFormat && bracketMatches.length >= 2;
      final isAngleMultiFormat = !isMixedFormat && angleMatches.length >= 2;

      late List<int> timestamps;
      late String realLyrics;
      late int lineStartTime;
      String? role;

      // 提取角色信息
      final roleMatch = rolePattern.firstMatch(line);
      if (roleMatch != null) {
        role = roleMatch.group(1);
      }

      // 基础文本处理
      String processedLine = line
          .replaceAll(valuePattern, '')
          .replaceAll(angleValuePattern, '')
          .replaceFirst(rolePattern, '')
          .replaceAll(RegExp(r'\s+'), '');

      realLyrics = processedLine.trim();
      final validChars =
          realLyrics.split('').where((c) => c.isNotEmpty).toList();

      if (isMixedFormat) {
        lineStartTime = _getFirstValidTime(line, valuePattern);
        timestamps = _extractAndDeduplicateTimestamps(angleMatches);
        if (timestamps.isNotEmpty && timestamps.first != lineStartTime) {
          timestamps.insert(0, lineStartTime);
        }
      } else if (isBracketMultiFormat) {
        timestamps = bracketMatches
            .map((m) => _timeToMs(m.group(1)!))
            .where((t) => t != -1)
            .toList();
        timestamps = _deduplicateTimestamps(timestamps);
        lineStartTime = timestamps.isNotEmpty ? timestamps.first : 0;
      } else if (isAngleMultiFormat) {
        lineStartTime = _getFirstValidTime(line, angleValuePattern);
        timestamps = _extractAndDeduplicateTimestamps(angleMatches);
      } else {
        lineStartTime = _getFirstValidTime(line, valuePattern);
        timestamps = [lineStartTime];
      }

      // 调整时间戳数量
      timestamps = _adjustTimestamps(timestamps, validChars.length);

      // 提取时间戳键（用于缓存匹配）
      final timeKey = _extractTimeKey(line);

      final res = LanguageAutoSplitter.splitMixedText(realLyrics);

      // 处理缓存逻辑
      if (timestampCache.containsKey(timeKey)) {
        // 已存在相同时间戳，作为翻译文本
        timestampCache[timeKey]!.model.extText = realLyrics;
      } else {
        // 新时间戳，作为原歌词文本
        final model = LyricsLineModel()
          ..startTime = lineStartTime
          ..mainText = realLyrics
          ..extText = "";

        timestampCache[timeKey] = _LineCache(
          model: model,
          realLyrics: realLyrics,
          timestamps: timestamps,
          role: role,
          validChars: validChars,
        );
      }

      if (res["extText"] != null && (res["extText"]?.length ?? 0) > 0) {
        timestampCache[timeKey]!.model.extText = res["extText"];
        timestampCache[timeKey]!.model.mainText = res["mainText"];
      }
    }

    // 生成最终结果列表
    final lineList = <LyricsLineModel>[];
    for (final cache in timestampCache.values) {
      final spanList = _generateValidSpanList(
        cache.realLyrics,
        cache.timestamps,
        cache.role,
        cache.validChars,
      );

      final lineEndTime = cache.timestamps.isNotEmpty
          ? cache.timestamps.last
          : cache.model.startTime;

      cache.model
        ..endTime = lineEndTime
        ..spanList = spanList;

      lineList.add(cache.model);
    }

    return lineList;
  }

  // 提取时间戳键
  String _extractTimeKey(String line) {
    final bracketMatch = valuePattern.firstMatch(line);
    if (bracketMatch != null) {
      return bracketMatch.group(0)!;
    }

    final angleMatch = angleValuePattern.firstMatch(line);
    if (angleMatch != null) {
      return angleMatch.group(0)!;
    }

    return line.substring(0, line.indexOf(']') + 1);
  }

  // 提取并去重时间戳
  List<int> _extractAndDeduplicateTimestamps(Iterable<RegExpMatch> matches) {
    final timestamps = matches
        .map((m) => _timeToMs(m.group(1)!))
        .where((t) => t != -1)
        .toList();
    return _deduplicateTimestamps(timestamps);
  }

  // 时间戳去重
  List<int> _deduplicateTimestamps(List<int> timestamps) {
    final uniqueTimestamps = <int>[];
    for (final t in timestamps) {
      if (!uniqueTimestamps.contains(t)) {
        uniqueTimestamps.add(t);
      }
    }
    return uniqueTimestamps;
  }

  // 调整时间戳数量
  List<int> _adjustTimestamps(List<int> timestamps, int charCount) {
    if (timestamps.isEmpty) return [];

    final targetLength = charCount + 1;
    final List<int> adjusted = List.from(timestamps);
    final lastTime = adjusted.last;

    while (adjusted.length < targetLength) {
      adjusted.add(lastTime);
    }

    if (adjusted.length > targetLength) {
      return adjusted.sublist(0, targetLength);
    }

    return adjusted;
  }

  // 生成有效span列表
  List<LyricSpanInfo> _generateValidSpanList(String realLyrics,
      List<int> timestamps, String? role, List<String> validChars) {
    final List<LyricSpanInfo> spanList = [];
    if (timestamps.length != validChars.length + 1) {
      LyricsLog.logW(
          "时间戳数量与字符数不匹配: ${timestamps.length} vs ${validChars.length + 1}");
      return spanList;
    }

    for (var i = 0; i < validChars.length; i++) {
      final start = timestamps[i];
      final end = timestamps[i + 1];
      final duration = end - start;

      if (duration <= 0) {
        LyricsLog.logW("忽略无效时长: $start-$end (${validChars[i]})");
        continue;
      }

      spanList.add(LyricSpanInfo()
        ..raw = validChars[i]
        ..start = start
        ..duration = duration
        ..index = i
        ..length = validChars[i].length
        ..role = role);
    }
    return spanList;
  }

  // 获取第一个有效的时间戳
  int _getFirstValidTime(String line, RegExp pattern) {
    final match = pattern.firstMatch(line);
    if (match == null) return 0;

    final timeStr = match.group(1)!;
    final timeMs = _timeToMs(timeStr);
    return timeMs != -1 ? timeMs : 0;
  }

  // 时间转换函数
  int _timeToMs(String timeStr) {
    try {
      final parts = timeStr.split(RegExp(r'[:.]'));
      if (parts.length != 3) return -1;

      final minutes = int.parse(parts[0].padLeft(2, '0'));
      final seconds = int.parse(parts[1].padLeft(2, '0'));
      final milliseconds = int.parse(parts[2].padRight(3, '0').substring(0, 3));

      return minutes * 60 * 1000 + seconds * 1000 + milliseconds;
    } catch (e) {
      LyricsLog.logD("时间解析失败: $timeStr，错误: $e");
      return -1;
    }
  }

  @override
  bool isValid() {
    return angleValuePattern.hasMatch(lyric) ||
        valuePattern.allMatches(lyric.split("\n")[0]).length >= 2;
  }
}

// 辅助类存储临时解析数据
class _LineCache {
  final LyricsLineModel model;
  final String realLyrics;
  final List<int> timestamps;
  final String? role;
  final List<String> validChars;

  _LineCache({
    required this.model,
    required this.realLyrics,
    required this.timestamps,
    this.role,
    required this.validChars,
  });
}
