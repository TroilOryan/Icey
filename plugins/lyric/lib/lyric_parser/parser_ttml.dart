import 'dart:io';
import 'package:xml/xml.dart';
import '../lyrics_log.dart';
import '../lyrics_reader_model.dart';
import 'lyrics_parse.dart';

/// 忽略命名空间的TTML解析器
class ParserTtml extends LyricsParse {
  ParserTtml(String lyric) : super(lyric);

  @override
  List<LyricsLineModel> parseLines({bool isMain = true}) {
    final List<LyricsLineModel> lineList = [];

    try {
      final document = XmlDocument.parse(lyric);
      final root = document.rootElement;

      // 忽略命名空间，直接查找所有p标签
      final pTags = root.findAllElements('p');

      for (final p in pTags) {
        // 提取时间属性
        final beginTimeStr = p.getAttribute('begin') ?? '';
        final endTimeStr = p.getAttribute('end') ?? '';

        if (beginTimeStr.isEmpty || endTimeStr.isEmpty) {
          LyricsLog.logD("跳过缺少时间属性的p标签");
          continue;
        }

        // 转换时间格式
        final startTime = _ttmlTimeToMs(beginTimeStr);
        final endTime = _ttmlTimeToMs(endTimeStr);

        if (startTime < 0 || endTime <= startTime) {
          LyricsLog.logD("跳过无效时间范围的p标签: $beginTimeStr-$endTimeStr");
          continue;
        }

        // 忽略命名空间，查找所有span标签
        final spans = p.findAllElements('span').toList();

        // 解析span信息
        final List<LyricSpanInfo> spanList = [];

        final List<LyricSpanInfo> extSpanList = [];

        for (int i = 0; i < spans.length; i++) {
          final span = spans[i];
          final spanBegin = span.getAttribute('begin') ?? '';
          final spanEnd = span.getAttribute('end') ?? '';
          final text = span.innerText;

          final isTranslation = span.getAttribute("ttm:role");

          if (isTranslation != null) {
            extSpanList.add(LyricSpanInfo()
              ..raw = text
              ..index = i
              ..length = text.length);
          }

          if (text.isEmpty || isTranslation != null) continue;

          // 计算span时间
          int spanStartTime;
          int spanDuration;

          if (spanBegin.isNotEmpty && spanEnd.isNotEmpty) {
            spanStartTime = _ttmlTimeToMs(spanBegin);
            final spanEndTime = _ttmlTimeToMs(spanEnd);
            spanDuration = spanEndTime - spanStartTime;
          } else {
            // 均匀分配时间
            final totalDuration = endTime - startTime;
            spanDuration = (totalDuration / spans.length).round();
            spanStartTime = startTime + (i * spanDuration);
          }

          if (spanDuration <= 0) continue;

          spanList.add(LyricSpanInfo()
            ..raw = text
            ..start = spanStartTime
            ..duration = spanDuration
            ..index = i
            ..length = text.length);
        }

        // 构建歌词行
        final mainText = spanList.map((s) => s.raw).join();

        final extText = extSpanList.map((s) => s.raw).join();

        lineList.add(LyricsLineModel()
          ..mainText = mainText
          ..extText = extText
          ..startTime = startTime
          ..endTime = endTime
          ..spanList = spanList);
      }

      LyricsLog.logD("TTML解析完成，共解析 ${lineList.length} 行歌词");
    } catch (e) {
      LyricsLog.logD("TTML解析错误: $e");
    }

    return lineList;
  }

  int _ttmlTimeToMs(String timeStr) {
    try {
      final parts = timeStr.split(':');
      double totalSeconds = 0.0;

      if (parts.length == 3) {
        totalSeconds = int.parse(parts[0]) * 3600 +
            int.parse(parts[1]) * 60 +
            double.parse(parts[2]);
      } else if (parts.length == 2) {
        totalSeconds = int.parse(parts[0]) * 60 + double.parse(parts[1]);
      } else if (parts.length == 1) {
        totalSeconds = double.parse(parts[0]);
      }

      return (totalSeconds * 1000).round();
    } catch (e) {
      LyricsLog.logD("时间解析失败: $timeStr");
      return -1;
    }
  }

  @override
  bool isValid() => lyric.contains('<tt') && lyric.contains('</tt>');
}
