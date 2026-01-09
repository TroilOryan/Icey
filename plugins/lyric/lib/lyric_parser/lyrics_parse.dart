import 'package:lyric/lyrics_reader_model.dart';

import '../lyrics_log.dart';

// 需要过滤的元数据key集合
const Set<String> _filteredMetadataKeys = {
  'ar',
  'al',
  'ti',
  'au',
  'length',
  'by',
  'offset',
  're',
  've',
};

///all parse extends this file
abstract class LyricsParse {
  String lyric;

  ///call this method parse
  List<LyricsLineModel> parseLines({bool isMain = true});

  ///verify [lyric] is matching
  bool isValid() => true;

  LyricsParse(this.lyric);

  String filterMetadataLines(String lyric) {
    // 精确匹配特定元数据行的正则表达式
    final specificMetadataPattern = RegExp(
        r'^\[(' + _filteredMetadataKeys.join('|') + r'):.+\]$',
        caseSensitive: false);

    // 仅过滤匹配的元数据行，保留其他所有内容
    return lyric
        .split("\n")
        .where((line) => !specificMetadataPattern.hasMatch(line.trim()))
        .join('\n');
  }
}
