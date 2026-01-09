import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:lyric/lyric_helper.dart';
import 'package:lyric/lyric_ui/lyric_ui.dart';

///lyric model
class LyricsReaderModel {
  List<LyricsLineModel> lyrics = [];

  int getCurrentLine(int progress) {
    // 边界处理：空列表返回0
    if (lyrics.isEmpty) {
      return 0;
    }

    // 初始化最接近索引和最小差值
    int closestIndex = 0;
    int minDiff = (lyrics[0].startTime ?? 0) - progress;
    minDiff = minDiff.abs(); // 取绝对值

    for (int i = 0; i < lyrics.length; i++) {
      final nextLine = lyrics[i + 1 >= lyrics.length ? i : i + 1];
      final line = lyrics[i];
      final startTime = line.startTime ?? 0;
      final endTime = nextLine.startTime ?? line.endTime ?? startTime;

      // 1. 优先检查是否在当前行时间区间内
      if (progress >= startTime && progress < endTime) {
        return i;
      }

      // 2. 计算与当前行的时间差（取绝对值）
      final currentDiff = (startTime - progress).abs();

      // 3. 更新最小差值和索引
      if (currentDiff <= minDiff) {
        minDiff = currentDiff;
        closestIndex = i;
      }
    }

    // 4. 未找到匹配区间时，返回最接近的索引
    return closestIndex;
  }

  double computeScroll(int toLine, int playLine, LyricUI ui) {
    if (toLine <= 0) return 0;

    final LyricsLineModel targetLine = lyrics[toLine];

    double offset = 0;

    if (!targetLine.hasExt && !targetLine.hasMain) {
      offset += ui.getBlankLineHeight() + ui.getLineSpace();
    } else {
      offset += ui.getLineSpace();

      offset += LyricHelper.centerOffset(
          targetLine, toLine == playLine, ui, playLine);
    }

    //需要特殊处理往上偏移的第一行
    return -LyricHelper.getTotalHeight(
          lyrics.sublist(0, toLine),
          playLine,
          ui,
        ) +
        firstCenterOffset(playLine, ui) -
        offset;
  }

  double firstCenterOffset(int playIndex, LyricUI lyricUI) {
    return LyricHelper.centerOffset(
        lyrics.firstOrNull, playIndex == 0, lyricUI, playIndex);
  }

  double lastCenterOffset(int playIndex, LyricUI lyricUI) {
    return LyricHelper.centerOffset(
        lyrics.lastOrNull, playIndex == lyrics.length - 1, lyricUI, playIndex);
  }
}

///lyric line model
class LyricsLineModel {
  String? mainText;
  String? extText;
  int? startTime;
  int? endTime;
  List<LyricSpanInfo>? spanList;

  //绘制信息
  LyricDrawInfo? drawInfo;

  bool get hasExt => extText?.isNotEmpty == true;

  bool get hasMain => mainText?.isNotEmpty == true;

  List<LyricSpanInfo>? _defaultSpanList;

  get defaultSpanList => _defaultSpanList ??= [
        LyricSpanInfo()
          ..duration = (endTime ?? 0) - (startTime ?? 0)
          ..start = startTime ?? 0
          ..length = mainText?.length ?? 0
          ..raw = mainText ?? ""
      ];
}

///lyric draw model
class LyricDrawInfo {
  double get otherMainTextHeight => otherMainTextPainter?.height ?? 0;

  double get otherExtTextHeight => otherExtTextPainter?.height ?? 0;

  double get playingMainTextHeight => playingMainTextPainter?.height ?? 0;

  double get playingExtTextHeight => playingExtTextPainter?.height ?? 0;

  TextPainter? otherMainTextPainter;

  TextPainter? otherExtTextPainter;

  TextPainter? playingMainTextPainter;

  TextPainter? playingExtTextPainter;

  List<LyricInlineDrawInfo> inlineDrawList = [];
}

class LyricInlineDrawInfo {
  int number = 0;
  String raw = "";
  double width = 0;
  double height = 0;
  Offset offset = Offset.zero;
}

class LyricSpanInfo {
  int index = 0;
  int length = 0;
  int duration = 0;
  int start = 0;
  String raw = "";

  String? role = "";

  double drawWidth = 0;
  double drawHeight = 0;

  int get end => start + duration;

  int get endIndex => index + length;
}

extension LyricsReaderModelExt on LyricsReaderModel? {
  get isNullOrEmpty => this?.lyrics == null || this!.lyrics.isEmpty;
}
