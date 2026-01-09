import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lyric/lyric_helper.dart';
import 'package:lyric/lyric_ui/lyric_ui.dart';
import 'package:lyric/lyrics_log.dart';
import 'package:lyric/lyrics_reader_model.dart';

///draw lyric reader
class LyricsReaderPaint extends ChangeNotifier implements CustomPainter {
  LyricsReaderModel? model;

  LyricUI lyricUI;

  bool blur;

  LyricsReaderPaint(this.model, this.lyricUI, this.blur);

  final double _maxBlurRadius = 2.0; // 最大模糊半径

  final double _blurFactor = 0.4; // 模糊因子

  final Map<double, Paint> _blurPaints = {}; // 模糊画笔缓存

  ///高亮混合笔
  Paint lightBlendPaint = Paint()
    ..blendMode = BlendMode.srcIn
    ..isAntiAlias = true;

  int playingIndex = 0;

  double _lyricOffset = 0;

  set lyricOffset(double offset) {
    if (checkOffset(offset)) {
      _lyricOffset = offset;

      refresh();
    }
  }

  double totalHeight = 0;

  int cachePlayingIndex = -1;

  void clearCache() {
    cachePlayingIndex = -1;
    highlightWidth = 0;
  }

  ///check offset illegal
  ///true is OK
  ///false is illegal
  bool checkOffset(double? offset) {
    if (offset == null) return false;

    calculateTotalHeight();

    if (offset >= maxOffset && offset <= 0) {
      return true;
    } else {
      if (offset <= maxOffset && offset > _lyricOffset) {
        return true;
      }
    }
    LyricsLog.logD("越界取消偏移 可偏移：$maxOffset 目标偏移：$offset 当前：$_lyricOffset ");
    return false;
  }

  ///calculateTotalHeight
  void calculateTotalHeight() {
    ///缓存下，避免多余计算
    if (cachePlayingIndex != playingIndex) {
      cachePlayingIndex = playingIndex;
      var lyrics = model?.lyrics ?? [];
      double lastLineSpace = 0;
      //最大偏移量不包含最后一行
      if (lyrics.isNotEmpty) {
        lyrics = lyrics.sublist(0, lyrics.length - 1);
        lastLineSpace = LyricHelper.getLineSpaceHeight(lyrics.last, lyricUI,
            excludeInline: true);
      }
      totalHeight = -LyricHelper.getTotalHeight(lyrics, playingIndex, lyricUI) +
          (model?.firstCenterOffset(playingIndex, lyricUI) ?? 0) -
          (model?.lastCenterOffset(playingIndex, lyricUI) ?? 0) -
          lastLineSpace;
    }
  }

  double get baseOffset => lyricUI.halfSizeLimit()
      ? canvasSize.height * (0.5 - lyricUI.getPlayingLineBias())
      : 0;

  double get maxOffset {
    calculateTotalHeight();
    return baseOffset + totalHeight;
  }

  double get lyricOffset => _lyricOffset;

  //限制刷新频率
  int ts = DateTime.now().microsecond;

  void refresh() {
    notifyListeners();
  }

  int _centerLyricIndex = 0;

  set centerLyricIndex(int value) {
    _centerLyricIndex = value;
    centerLyricIndexChangeCall?.call(value);
  }

  int get centerLyricIndex => _centerLyricIndex;

  Function(int)? centerLyricIndexChangeCall;

  Size canvasSize = Size.zero;

  ///给外部C位位置
  double centerY = 0.0;

  double drawLine(
      int i, double drawOffset, Canvas canvas, LyricsLineModel element) {
    //空行直接返回
    if (!element.hasMain && !element.hasExt) {
      return lyricUI.getBlankLineHeight();
    }

    return _drawOtherLyricLine(canvas, drawOffset, element, i);
  }

  ///绘制其他歌词行
  ///返回造成的偏移量值
  double _drawOtherLyricLine(Canvas canvas, double drawOffsetY,
      LyricsLineModel element, int lineIndex) {
    final bool isPlaying = lineIndex == playingIndex;

    final TextPainter? mainTextPainter = (isPlaying
        ? element.drawInfo?.playingMainTextPainter
        : element.drawInfo?.otherMainTextPainter);
    final TextPainter? extTextPainter = (isPlaying
        ? element.drawInfo?.playingExtTextPainter
        : element.drawInfo?.otherExtTextPainter);

    //该行行高
    double otherLineHeight = 0;

    //第一行不加行间距
    if (lineIndex != 0) {
      otherLineHeight += lyricUI.getLineSpace();
    }

    double nextOffsetY = drawOffsetY + otherLineHeight;

    if (element.hasMain) {
      otherLineHeight += drawText(
        canvas,
        mainTextPainter,
        nextOffsetY,
        lineIndex,
        isPlaying ? element : null,
      );
    }

    if (element.hasExt) {
      //有主歌词时才加内间距
      //翻译歌词贴紧主歌词
      if (element.hasMain) {
        otherLineHeight += lyricUI.getInlineSpace();
      }

      double extOffsetY = drawOffsetY + otherLineHeight;

      otherLineHeight +=
          drawText(canvas, extTextPainter, extOffsetY, lineIndex);
    }

    return otherLineHeight;
  }

  void drawHighlight(LyricsLineModel model, Canvas canvas, TextPainter? painter,
      Offset offset) {
    if (!model.hasMain) return;

    double tmpHighlightWidth = _highlightWidth;
    model.drawInfo?.inlineDrawList.forEach((element) {
      if (tmpHighlightWidth < 0) {
        return;
      }
      double currentWidth = 0.0;
      if (tmpHighlightWidth >= element.width) {
        currentWidth = element.width;
      } else {
        currentWidth = element.width - (element.width - tmpHighlightWidth);
      }
      tmpHighlightWidth -= currentWidth;
      double dx = offset.dx + element.offset.dx;
      if (lyricUI.getHighlightDirection() == HighlightDirection.RTL) {
        dx += element.width;
        dx -= currentWidth;
      }
      canvas.drawRect(
          Rect.fromLTWH(dx, offset.dy + element.offset.dy - 2, currentWidth,
              element.height + 2),
          lightBlendPaint..color = lyricUI.getLyricHighlightColor());
    });
  }

  double _highlightWidth = 0.0;

  set highlightWidth(double value) {
    _highlightWidth = value;
    refresh();
  }

  double get highlightWidth => _highlightWidth;

  final Paint layerPaint = Paint();

  double _calculateBlurRadius(int lineIndex) {
    if (lineIndex == playingIndex) return 0;
    final int distance = (lineIndex - playingIndex).abs();
    final double blurRadius = distance * _blurFactor;
    return blurRadius > _maxBlurRadius ? _maxBlurRadius : blurRadius;
  }

// 获取缓存的模糊画笔
  Paint _getBlurPaint(double sigma) {
    final double key = double.parse(sigma.toStringAsFixed(1));

    if (!_blurPaints.containsKey(key)) {
      _blurPaints[key] = Paint()
        ..imageFilter = ImageFilter.blur(sigmaX: key, sigmaY: key);
    }

    return _blurPaints[key]!;
  }

  ///绘制文本并返回行高度
  ///when [element] not null,then draw gradient
  double drawText(
      Canvas canvas, TextPainter? paint, double offsetY, int lineIndex,
      [LyricsLineModel? element]) {
    //paint 理论上不可能为空，预期报错
    final double lineHeight = paint!.height;

    if (offsetY < 0 - lineHeight || offsetY > canvasSize.height) {
      return lineHeight;
    }

    final bool isEnableHighLight = element != null && lyricUI.enableHighlight();

    final Offset offset = Offset(getLineOffsetX(paint), offsetY);

    if (isEnableHighLight) {
      canvas.saveLayer(
          Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height), layerPaint);
    }

    final double blurRadius = _calculateBlurRadius(lineIndex);

    if (blurRadius > 0 && blur) {
      final Paint blurPaint = _getBlurPaint(blurRadius);

      canvas.saveLayer(
          Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height), blurPaint);
    }

    paint.paint(canvas, offset);

    if (isEnableHighLight) {
      drawHighlight(element, canvas, paint, offset);

      canvas.restore();
    }

    if (blurRadius > 0 && blur) {
      canvas.restore();
    }

    return lineHeight;
  }

  ///获取行绘制横向坐标
  double getLineOffsetX(TextPainter textPainter) {
    switch (lyricUI.getLyricHorizontalAlign()) {
      case LyricAlign.LEFT:
        return 0;
      case LyricAlign.CENTER:
        return (canvasSize.width - textPainter.width) / 2;
      case LyricAlign.RIGHT:
        return canvasSize.width - textPainter.width;
      default:
        return (canvasSize.width - textPainter.width) / 2;
    }
  }

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) =>
      shouldRepaint(oldDelegate);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  bool? hitTest(Offset position) => false;

  @override
  void paint(Canvas canvas, Size size) {
    //全局尺寸信息
    canvasSize = size;
    //溢出裁剪
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height));

    centerY = size.height * lyricUI.getPlayingLineBias();

    double drawOffset = centerY + _lyricOffset - playingIndex;

    List<LyricsLineModel> lyrics = model?.lyrics ?? [];

    drawOffset -= model?.firstCenterOffset(playingIndex, lyricUI) ?? 0;

    for (int i = 0; i < lyrics.length; i++) {
      final LyricsLineModel element = lyrics[i];

      final double lineHeight = drawLine(i, drawOffset, canvas, element);

      final double nextOffset = drawOffset + lineHeight;

      if (centerY > drawOffset && centerY < nextOffset) {
        if (i != centerLyricIndex) {
          centerLyricIndex = i;
          LyricsLog.logD(
              "drawOffset:$drawOffset next:$nextOffset center:$centerY  当前行是：$i 文本：${element.mainText} ");
        }
      }

      drawOffset = nextOffset;
    }
  }
}
