import './lyric_model.dart';

/// LRC歌词解析器
/// 支持标准LRC格式和增强LRC格式（逐字时间戳）
class LyricParser {
  /// 解析LRC格式歌词
  /// 
  /// 支持格式：
  /// - 标准: [00:12.00]歌词内容
  /// - 增强: [00:12.00]<0,200>歌<200,150>词
  /// 
  /// 示例：
  /// ```dart
  /// final lrc = '''
  /// [ti:歌曲名]
  /// [ar:艺术家]
  /// [00:00.00]第一句歌词
  /// [00:05.00]第二句歌词
  /// ''';
  /// final lyrics = LyricParser.parse(lrc);
  /// ```
  static Lyrics parse(String lrcContent, {String? title, String? artist}) {
    final lines = <LyricLine>[];
    
    String? parsedTitle = title;
    String? parsedArtist = artist;
    
    final lineStrings = lrcContent.split('\n');
    
    for (var lineString in lineStrings) {
      lineString = lineString.trim();
      if (lineString.isEmpty) continue;
      
      // 解析元数据标签
      if (lineString.startsWith('[ti:')) {
        parsedTitle ??= _extractTag(lineString, 'ti');
        continue;
      }
      if (lineString.startsWith('[ar:')) {
        parsedArtist ??= _extractTag(lineString, 'ar');
        continue;
      }
      
      // 解析歌词行
      final line = _parseLine(lineString);
      if (line != null) {
        lines.add(line);
      }
    }
    
    // 按开始时间排序
    lines.sort((a, b) => a.start.compareTo(b.start));
    
    return Lyrics(
      title: parsedTitle,
      artist: parsedArtist,
      lines: lines,
    );
  }
  
  /// 解析单行歌词
  static LyricLine? _parseLine(String lineString) {
    // 提取时间戳
    final timeMatch = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\]').firstMatch(lineString);
    if (timeMatch == null) return null;
    
    final minutes = int.parse(timeMatch.group(1)!);
    final seconds = int.parse(timeMatch.group(2)!);
    final milliseconds = int.parse(timeMatch.group(3)!.padRight(3, '0'));
    
    final startTime = Duration(
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
    
    // 获取歌词文本（移除时间戳）
    var text = lineString.substring(timeMatch.end).trim();
    
    // 检查是否有逐字时间戳（增强LRC格式）
    // 格式: <开始偏移,持续时间>字
    final wordPattern = RegExp(r'<(\d+),(\d+)>([^<]+)');
    final wordMatches = wordPattern.allMatches(text);
    
    List<LyricWord>? words;
    
    if (wordMatches.isNotEmpty) {
      words = [];
      var cleanText = StringBuffer();
      
      for (var match in wordMatches) {
        final wordStart = int.parse(match.group(1)!);
        final wordDuration = int.parse(match.group(2)!);
        final wordText = match.group(3)!;
        
        cleanText.write(wordText);
        
        final wordStartTime = startTime + Duration(milliseconds: wordStart);
        final wordEndTime = wordStartTime + Duration(milliseconds: wordDuration);
        
        words.add(LyricWord(
          text: wordText,
          start: wordStartTime,
          end: wordEndTime,
        ));
      }
      
      text = cleanText.toString();
    }
    
    return LyricLine(
      start: startTime,
      text: text,
      words: words,
    );
  }
  
  /// 提取标签内容
  static String _extractTag(String line, String tagName) {
    final match = RegExp('\\[$tagName:(.+)\\]').firstMatch(line);
    return match?.group(1)?.trim() ?? '';
  }
  
  /// 解析带有翻译的歌词
  /// 
  /// 格式：原文和翻译交替，翻译行以 @ 开头
  /// 示例：
  /// ```
  /// [00:00.00]Hello world
  /// @你好世界
  /// [00:05.00]How are you
  /// @你好吗
  /// ```
  static Lyrics parseWithTranslation(String lrcContent, {String? title, String? artist}) {
    final lines = <LyricLine>[];
    
    String? parsedTitle = title;
    String? parsedArtist = artist;
    
    final lineStrings = lrcContent.split('\n');
    LyricLine? lastLine;
    
    for (var lineString in lineStrings) {
      lineString = lineString.trim();
      if (lineString.isEmpty) continue;
      
      // 解析元数据标签
      if (lineString.startsWith('[ti:')) {
        parsedTitle ??= _extractTag(lineString, 'ti');
        continue;
      }
      if (lineString.startsWith('[ar:')) {
        parsedArtist ??= _extractTag(lineString, 'ar');
        continue;
      }
      
      // 检查是否为翻译行
      if (lineString.startsWith('@')) {
        if (lastLine != null) {
          // 创建带翻译的新行
          lastLine = LyricLine(
            start: lastLine.start,
            end: lastLine.end,
            text: lastLine.text,
            translation: lineString.substring(1).trim(),
            words: lastLine.words,
          );
          // 替换最后一行
          if (lines.isNotEmpty) {
            lines.removeLast();
          }
          lines.add(lastLine);
        }
        continue;
      }
      
      // 解析歌词行
      final line = _parseLine(lineString);
      if (line != null) {
        if (lastLine != null && lastLine.translation == null) {
          lines.add(lastLine);
        }
        lastLine = line;
      }
    }
    
    // 添加最后一行
    if (lastLine != null) {
      lines.add(lastLine);
    }
    
    // 按开始时间排序
    lines.sort((a, b) => a.start.compareTo(b.start));
    
    return Lyrics(
      title: parsedTitle,
      artist: parsedArtist,
      lines: lines,
    );
  }
}

/// QRC格式歌词解析器（QQ音乐格式）
/// 支持更精确的逐字时间信息
class QrcParser {
  /// 解析QRC格式歌词
  /// QRC是一种二进制压缩格式，这里只解析解压后的文本格式
  static Lyrics parse(String qrcContent, {String? title, String? artist}) {
    final lines = <LyricLine>[];
    
    final lineStrings = qrcContent.split('\n');
    
    for (var lineString in lineStrings) {
      lineString = lineString.trim();
      if (lineString.isEmpty) continue;
      
      final line = _parseQrcLine(lineString);
      if (line != null) {
        lines.add(line);
      }
    }
    
    lines.sort((a, b) => a.start.compareTo(b.start));
    
    return Lyrics(
      title: title,
      artist: artist,
      lines: lines,
    );
  }
  
  static LyricLine? _parseQrcLine(String lineString) {
    // QRC格式: [时间,时长](字1,开始,时长)(字2,开始,时长)...
    final headerMatch = RegExp(r'\[(\d+),(\d+)\]').firstMatch(lineString);
    if (headerMatch == null) return null;
    
    final startTime = Duration(milliseconds: int.parse(headerMatch.group(1)!));
    final duration = int.parse(headerMatch.group(2)!);
    final endTime = startTime + Duration(milliseconds: duration);
    
    var text = lineString.substring(headerMatch.end);
    
    // 解析逐字信息
    final wordPattern = RegExp(r'\(([^,]+),(\d+),(\d+)\)');
    final wordMatches = wordPattern.allMatches(text);
    
    List<LyricWord> words = [];
    var cleanText = StringBuffer();
    
    for (var match in wordMatches) {
      final wordText = match.group(1)!;
      final wordStart = int.parse(match.group(2)!);
      final wordDuration = int.parse(match.group(3)!);
      
      cleanText.write(wordText);
      
      final wordStartTime = startTime + Duration(milliseconds: wordStart);
      final wordEndTime = wordStartTime + Duration(milliseconds: wordDuration);
      
      words.add(LyricWord(
        text: wordText,
        start: wordStartTime,
        end: wordEndTime,
      ));
    }
    
    return LyricLine(
      start: startTime,
      end: endTime,
      text: cleanText.toString(),
      words: words.isNotEmpty ? words : null,
    );
  }
}
