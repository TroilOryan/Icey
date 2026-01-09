import 'package:flutter/services.dart';

/// 增强版语言自动识别与拆分工具
class LanguageAutoSplitter {
  /// 支持的语言及其Unicode范围
  static final Map<String, RegExp> _languagePatterns = {
    'zh': RegExp(r'[\u4e00-\u9fa5]'),
    // 中文
    'en': RegExp(r'[A-Za-z]'),
    // 英文
    'ko': RegExp(r'[\uac00-\ud7af]'),
    // 韩文
    'ja': RegExp(r'[\u3040-\u309f\u30a0-\u30ff]'),
    // 日文
    'other': RegExp(r'[^\u4e00-\u9fa5A-Za-z\uac00-\ud7af\u3040-\u30ff]'),
    // 其他字符
  };

  /// 常见语言对优先级 (主语言在前)
  static const Map<List<String>, int> _languagePriority = {
    ['en', 'zh']: 0, // 英文优先于中文
    ['zh', 'en']: 1, // 中文优先于英文
    ['en', 'ko']: 0, // 英文优先于韩文
    ['ko', 'en']: 1, // 韩文优先于英文
    ['en', 'ja']: 0, // 英文优先于日文
    ['ja', 'en']: 1, // 日文优先于英文
  };

  /// 不应拆分的模式（包含这些字符的文本不拆分）
  static final RegExp _nonTranslationPattern = RegExp(r'[\-:()（）【】\[\]]');

  /// 自动识别并拆分混杂的两种语言文本
  static Map<String, String> splitMixedText(String text) {
    text = text.trim();
    if (text.isEmpty) return {'mainText': '', 'extText': ''};

    // 1. 检查是否为非翻译文本（如歌曲信息）
    if (_nonTranslationPattern.hasMatch(text)) {
      return {'mainText': text, 'extText': ''};
    }

    // 2. 按语言分组
    final List<String> groups = _groupByLanguage(text);
    if (groups.length < 2) {
      return {'mainText': text, 'extText': ''};
    }

    // 3. 统计语言分布
    final Map<String, int> langCounts = _countLanguages(groups);

    // 4. 提取主要语言和次要语言
    final List<String> languages =
        langCounts.keys.where((lang) => lang != 'other').toList();

    if (languages.length < 2) {
      return {'mainText': text, 'extText': ''};
    }

    // 5. 根据优先级确定主语言
    final String mainLang;
    final String extLang;

    // 检查是否有明确的优先级
    final priorityKey = [languages[0], languages[1]];
    if (_languagePriority.containsKey(priorityKey)) {
      mainLang =
          _languagePriority[priorityKey] == 0 ? languages[0] : languages[1];
      extLang = mainLang == languages[0] ? languages[1] : languages[0];
    } else {
      // 按字符总数确定主语言
      final langCharCounts = _countLanguageChars(text);
      mainLang = langCharCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      extLang = languages.firstWhere((lang) => lang != mainLang);
    }

    // 6. 合并文本
    final String mainText = _mergeGroupsByLanguage(groups, mainLang).trim();
    final String extText = _mergeGroupsByLanguage(groups, extLang).trim();

    return {'mainText': mainText, 'extText': extText};
  }

  /// 按字符数统计语言分布
  static Map<String, int> _countLanguageChars(String text) {
    final counts = <String, int>{'zh': 0, 'en': 0, 'ko': 0, 'ja': 0};

    for (final char in text.split('')) {
      for (final entry in _languagePatterns.entries) {
        if (entry.key == 'other') continue;
        if (entry.value.hasMatch(char)) {
          counts[entry.key] = (counts[entry.key] ?? 0) + 1;
          break;
        }
      }
    }

    return counts;
  }

  /// 将文本按语言分组
  static List<String> _groupByLanguage(String text) {
    final List<String> groups = [];
    if (text.isEmpty) return groups;

    String currentGroup = text[0];
    String currentLang = _detectLanguage(text[0]);

    for (int i = 1; i < text.length; i++) {
      final String char = text[i];
      final String lang = _detectLanguage(char);

      if (lang == currentLang || lang == 'other') {
        currentGroup += char;
      } else {
        groups.add(currentGroup);
        currentGroup = char;
        currentLang = lang;
      }
    }

    groups.add(currentGroup);
    return groups;
  }

  /// 检测单个字符的语言
  static String _detectLanguage(String char) {
    for (final entry in _languagePatterns.entries) {
      if (entry.value.hasMatch(char)) {
        return entry.key;
      }
    }
    return 'other';
  }

  /// 统计各组语言分布
  static Map<String, int> _countLanguages(List<String> groups) {
    final Map<String, int> counts = {};

    for (final group in groups) {
      final String trimmedGroup = group.trim();
      if (trimmedGroup.isEmpty) continue;

      final String lang = _detectLanguage(trimmedGroup[0]);
      counts[lang] = (counts[lang] ?? 0) + 1;
    }

    return counts;
  }

  /// 按语言合并组
  static String _mergeGroupsByLanguage(List<String> groups, String targetLang) {
    final StringBuffer buffer = StringBuffer();

    for (final group in groups) {
      final String trimmedGroup = group.trim();
      if (trimmedGroup.isEmpty) continue;

      final String lang = _detectLanguage(trimmedGroup[0]);
      if (lang == targetLang || lang == 'other') {
        buffer.write(group);
      }
    }

    return buffer.toString();
  }

  /// 测试方法
  static void test() {
    final testCases = [
      "I'm ok 我很好",
      "Just gonna stand there and watch me burn 就站在那里看我燃烧殆尽",
      "鸽子 - 宋冬野 (Donye.S)",
      "안녕하세요 Hello",
      "こんにちは 你好",
      "Hello world",
      "我爱你 I love you",
      "C'est la vie 这就是生活",
      "123测试 Test",
    ];

    for (final testCase in testCases) {
      final result = splitMixedText(testCase);
      print('输入: "$testCase"');
      print('输出: 主文本="$result[mainText]", 翻译="$result[extText]"');
      print('---');
    }
  }
}

// 示例用法
void main() {
  LanguageAutoSplitter.test();
}
