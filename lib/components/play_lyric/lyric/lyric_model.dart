import 'dart:ui';

/// 单词/逐字信息
class LyricWord {
  final String text; // 单词/字文本
  final Duration start; // 相对于整首歌的起始时间
  final Duration? end; // 相对于整首歌的结束时间

  LyricWord({
    required this.text,
    required this.start,
    this.end,
  });

  /// 获取该字的持续时间
  Duration get duration {
    if (end != null) {
      return end! - start;
    }
    return const Duration(milliseconds: 300); // 默认持续时间
  }

  /// 计算在指定时间点的进度 (0.0 - 1.0)
  double getProgress(Duration currentTime) {
    if (currentTime < start) return 0.0;
    if (end == null || currentTime >= end!) return 1.0;
    
    final totalDuration = end! - start;
    final elapsed = currentTime - start;
    return elapsed.inMilliseconds / totalDuration.inMilliseconds;
  }

  /// 判断该字是否正在高亮
  bool isActive(Duration currentTime) {
    if (currentTime < start) return false;
    if (end == null) return currentTime >= start;
    return currentTime >= start && currentTime < end!;
  }

  /// 判断该字是否已完成
  bool isCompleted(Duration currentTime) {
    if (end == null) return currentTime > start;
    return currentTime >= end!;
  }

  @override
  String toString() {
    return 'LyricWord(text: $text, start: $start, end: $end)';
  }

  /// 从JSON创建
  factory LyricWord.fromJson(Map<String, dynamic> json) {
    return LyricWord(
      text: json['text'] as String,
      start: Duration(milliseconds: json['start'] as int),
      end: json['end'] != null 
          ? Duration(milliseconds: json['end'] as int) 
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'start': start.inMilliseconds,
      'end': end?.inMilliseconds,
    };
  }
}

/// 单行歌词
class LyricLine {
  final Duration start; // 行开始时间
  final Duration? end; // 行结束时间，可选
  final String text; // 行文本
  final List<LyricWord>? words; // 可选：逐字高亮信息
  final String? translation; // 翻译

  LyricLine({
    required this.start,
    this.end,
    required this.text,
    this.translation,
    this.words,
  });

  /// 获取该行的持续时间
  Duration get duration {
    if (end != null) {
      return end! - start;
    }
    return const Duration(seconds: 3); // 默认持续时间
  }

  /// 判断该行是否正在播放
  bool isActive(Duration currentTime) {
    if (currentTime < start) return false;
    if (end == null) {
      // 如果没有结束时间，判断是否在开始后的合理时间内
      return currentTime >= start && 
             currentTime < start + const Duration(seconds: 5);
    }
    return currentTime >= start && currentTime < end!;
  }

  /// 判断该行是否已播放完成
  bool isCompleted(Duration currentTime) {
    if (end == null) {
      return currentTime > start + const Duration(seconds: 5);
    }
    return currentTime >= end!;
  }

  /// 获取当前行的整体进度 (0.0 - 1.0)
  double getProgress(Duration currentTime) {
    if (currentTime < start) return 0.0;
    if (end == null || currentTime >= end!) return 1.0;
    
    final totalDuration = end! - start;
    final elapsed = currentTime - start;
    return elapsed.inMilliseconds / totalDuration.inMilliseconds;
  }

  /// 获取当前正在高亮的字的索引
  int? getActiveWordIndex(Duration currentTime) {
    if (words == null || words!.isEmpty) return null;
    
    for (int i = 0; i < words!.length; i++) {
      if (words![i].isActive(currentTime)) {
        return i;
      }
    }
    return null;
  }

  /// 判断是否有逐字信息
  bool get hasWords => words != null && words!.isNotEmpty;

  /// 判断是否有翻译
  bool get hasTranslation => translation != null && translation!.isNotEmpty;

  @override
  String toString() {
    return 'LyricLine(start: $start, end: $end, text: $text, translation: $translation, words: $words)';
  }

  /// 从JSON创建
  factory LyricLine.fromJson(Map<String, dynamic> json) {
    return LyricLine(
      start: Duration(milliseconds: json['start'] as int),
      end: json['end'] != null 
          ? Duration(milliseconds: json['end'] as int) 
          : null,
      text: json['text'] as String,
      translation: json['translation'] as String?,
      words: json['words'] != null
          ? (json['words'] as List)
              .map((w) => LyricWord.fromJson(w as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'start': start.inMilliseconds,
      'end': end?.inMilliseconds,
      'text': text,
      'translation': translation,
      'words': words?.map((w) => w.toJson()).toList(),
    };
  }
}

/// 歌词数据
class Lyrics {
  final List<LyricLine> lines;
  final String? title;
  final String? artist;

  Lyrics({
    required this.lines,
    this.title,
    this.artist,
  });

  /// 根据时间获取当前活跃的行索引
  int getActiveLineIndex(Duration currentTime) {
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].isActive(currentTime)) {
        return i;
      }
    }
    
    // 如果没有找到正在播放的行，返回最近的已播放行
    for (int i = lines.length - 1; i >= 0; i--) {
      if (lines[i].isCompleted(currentTime)) {
        return i;
      }
    }
    
    return -1;
  }

  /// 根据时间获取当前行
  LyricLine? getActiveLine(Duration currentTime) {
    final index = getActiveLineIndex(currentTime);
    if (index >= 0 && index < lines.length) {
      return lines[index];
    }
    return null;
  }

  /// 判断是否为空
  bool get isEmpty => lines.isEmpty;
  
  /// 判断是否不为空
  bool get isNotEmpty => lines.isNotEmpty;

  /// 总时长
  Duration get totalDuration {
    if (lines.isEmpty) return Duration.zero;
    final lastLine = lines.last;
    return lastLine.end ?? lastLine.start + const Duration(seconds: 5);
  }

  @override
  String toString() {
    return 'Lyrics(title: $title, artist: $artist, lines: ${lines.length})';
  }

  /// 从JSON创建
  factory Lyrics.fromJson(Map<String, dynamic> json) {
    return Lyrics(
      lines: (json['lines'] as List)
          .map((l) => LyricLine.fromJson(l as Map<String, dynamic>))
          .toList(),
      title: json['title'] as String?,
      artist: json['artist'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'lines': lines.map((l) => l.toJson()).toList(),
    };
  }
}
