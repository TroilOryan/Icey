import 'package:flutter_lyric/core/lyric_model.dart';
import 'package:flutter_lyric/core/lyric_parse.dart';
import 'package:xml/xml.dart' as xml;
import 'package:xml/xml.dart';

class TtmlParser extends LyricParse {
  @override
  bool isMatch(String mainLyric) {
    // 检查是否包含 TTML 根元素或命名空间
    return mainLyric.trim().startsWith('<tt') ||
        mainLyric.contains('xmlns="http://www.w3.org/ns/ttml"') ||
        mainLyric.contains("xmlns='http://www.w3.org/ns/ttml'");
  }

  @override
  LyricModel parseRaw(String mainLyric, {String? translationLyric}) {
    final Map<String, String> idTags = {};
    final List<LyricLine> lines = [];

    try {
      // 解析 XML 文档
      final XmlDocument document = XmlDocument.parse(mainLyric);

      // 获取根元素（修正：使用 rootElement 而不是 documentElement）
      final rootElement = document.rootElement;
      if (rootElement.localName != 'tt') {
        return LyricModel(lines: lines, tags: idTags);
      }

      // 提取 metadata（如果存在）
      final metadataElement = rootElement.findElements('metadata').firstOrNull;
      if (metadataElement != null) {
        _extractMetadata(metadataElement, idTags);
      }

      // 获取 body 元素
      final bodyElement = rootElement.findElements('body').firstOrNull;
      if (bodyElement == null) {
        return LyricModel(lines: lines, tags: idTags);
      }

      // 递归查找所有的 p 元素（段落/歌词行）
      final paragraphs = _findAllParagraphs(bodyElement);

      for (final p in paragraphs) {
        // 提取开始时间
        final beginTime = _parseTtmlTime(p.getAttribute('begin'));
        if (beginTime == null) continue;

        // 提取结束时间（可选）
        final endTime = _parseTtmlTime(p.getAttribute('end'));

        // 检查是否是逐字歌词（p 标签内有带 begin/end 的 span 标签）
        final hasWordTiming = p
            .findAllElements('span')
            .any((span) => span.getAttribute('begin') != null);

        if (hasWordTiming) {
          // 解析逐字歌词
          final lyricLine = _parseWordLevelLyric(p, beginTime);
          if (lyricLine != null) {
            lines.add(lyricLine);
          }
        } else {
          // 解析普通歌词
          final lyricLine = _parseNormalLyric(p, beginTime);
          if (lyricLine != null) {
            lines.add(lyricLine);
          }
        }
      }

      // 按开始时间排序
      lines.sort((a, b) => a.start.compareTo(b.start));
    } catch (e) {
      // 解析失败，返回空列表
      print('TTML 解析错误: $e');
    }

    return LyricModel(lines: lines, tags: idTags);
  }

  // 递归查找所有的 p 元素
  List<xml.XmlElement> _findAllParagraphs(xml.XmlElement element) {
    final List<xml.XmlElement> paragraphs = [];

    // 检查当前元素是否是 p
    if (element.localName == 'p') {
      paragraphs.add(element);
    }

    // 递归检查子元素
    for (final child in element.children) {
      if (child is xml.XmlElement) {
        paragraphs.addAll(_findAllParagraphs(child));
      }
    }

    return paragraphs;
  }

  // 解析逐字歌词
  LyricLine? _parseWordLevelLyric(xml.XmlElement p, Duration startTime) {
    final List<LyricWord> words = [];
    String? translation;
    String fullText = '';

    // 遍历所有 span 标签
    final spans = p.findElements('span');

    for (final span in spans) {
      // 检查是否是翻译
      final role = span.getAttribute('ttm:role');
      if (role == 'x-translation') {
        // 提取翻译文本
        translation = _extractTextContent(span);
        continue;
      }

      // 解析逐字时间
      final beginTime = _parseTtmlTime(span.getAttribute('begin'));
      final endTime = _parseTtmlTime(span.getAttribute('end'));

      // 提取文本
      final text = _extractTextContent(span);
      fullText += text;

      // 创建 LyricWord
      if (beginTime != null) {
        words.add(LyricWord(text: text, start: beginTime, end: endTime));
      }
    }

    // 过滤空内容
    fullText = fullText;
    if (fullText.isEmpty) return null;
    if (fullText == '//' || fullText.startsWith('//')) return null;

    return LyricLine(
      start: startTime,
      text: fullText,
      translation: translation?.isEmpty == true ? null : translation,
      words: words.isEmpty ? null : words,
    );
  }

  // 解析普通歌词
  LyricLine? _parseNormalLyric(xml.XmlElement p, Duration startTime) {
    String fullText = _extractTextContent(p);
    String? translation;

    // 检查是否包含翻译
    final spans = p.findElements('span');
    for (final span in spans) {
      final role = span.getAttribute('ttm:role');
      if (role == 'x-translation') {
        translation = _extractTextContent(span);
        break;
      }
    }

    // 过滤空内容
    if (fullText.isEmpty) return null;
    if (fullText == '//' || fullText.startsWith('//')) return null;

    return LyricLine(
      start: startTime,
      text: fullText,
      translation: translation?.isEmpty == true ? null : translation,
      words: null,
    );
  }

  // 解析 TTML 时间格式
  Duration? _parseTtmlTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;

    timeStr = timeStr.trim();

    try {
      // 格式1: 00:06.237 (分:秒.毫秒) 或 03:25.065 (时:分:秒.毫秒)
      final match = RegExp(r'^(\d{2}):(\d{2})\.(\d{3})$').firstMatch(timeStr);
      if (match != null) {
        final part1 = int.parse(match.group(1)!);
        final part2 = int.parse(match.group(2)!);
        final milliseconds = int.parse(match.group(3)!);

        // 如果第一部分大于等于60，说明是时:分:秒.毫秒格式
        if (part1 >= 60) {
          return Duration(
            hours: part1,
            minutes: part2,
            milliseconds: milliseconds,
          );
        } else {
          // 否则是分:秒.毫秒格式
          return Duration(
            minutes: part1,
            seconds: part2,
            milliseconds: milliseconds,
          );
        }
      }

      // 格式2: 0.76s (秒）
      if (timeStr.endsWith('s')) {
        final secondsStr = timeStr.substring(0, timeStr.length - 1);
        final seconds = double.parse(secondsStr);
        final milliseconds = (seconds * 1000).round();
        return Duration(milliseconds: milliseconds);
      }
    } catch (e) {
      print('时间解析错误: $timeStr, $e');
    }

    return null;
  }

  // 提取文本内容（去除 XML 标签）
  String _extractTextContent(xml.XmlElement element) {
    final StringBuffer buffer = StringBuffer();

    for (final child in element.children) {
      if (child is xml.XmlText) {
        // 不 trim，保留原始空格
        buffer.write(child.value);
      } else if (child is xml.XmlElement) {
        // 处理 br 标签（换行）
        if (child.localName == 'br') {
          buffer.write('\n');
        } else {
          // 递归处理其他标签
          buffer.write(_extractTextContent(child));
        }
      }
    }

    return buffer.toString();
  }

  // 提取 metadata 信息
  void _extractMetadata(xml.XmlElement metadataElement, Map idTags) {
    // 提取 title
    final titleElements = metadataElement.findAllElements('title');
    for (final titleElement in titleElements) {
      final title = titleElement.innerText.trim();
      if (title.isNotEmpty) {
        idTags['title'] = title;
        break;
      }
    }

    // 提取 copyright
    final copyrightElements = metadataElement.findAllElements('copyright');
    for (final copyrightElement in copyrightElements) {
      final copyright = copyrightElement.innerText.trim();
      if (copyright.isNotEmpty) {
        idTags['copyright'] = copyright;
        break;
      }
    }

    // 提取 agent（歌手信息）
    final agentElements = metadataElement.findAllElements('agent');
    for (final agentElement in agentElements) {
      final id = agentElement.getAttribute('xml:id');
      final type = agentElement.getAttribute('type');
      if (id != null && type != null) {
        idTags['agent_$id'] = type;
      }
    }
  }
}
