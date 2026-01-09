import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:lyric/lyric_ui/lyric_ui.dart';

class CustomUI extends LyricUI {
  ValueKey? key;
  double defaultSize;
  double defaultExtSize;
  double otherMainSize;
  double bias;
  double lineGap;
  double inlineGap;
  LyricAlign lyricAlign;
  LyricBaseLine lyricBaseLine;
  bool highlight;
  HighlightDirection highlightDirection;
  TextStyle? textStyle;
  TextStyle? activeTextStyle;
  TextStyle? extTextStyle;
  Color? highlightColor;

  CustomUI({
    this.key,
    this.highlightColor,
    this.textStyle,
    this.activeTextStyle,
    this.extTextStyle,
    this.defaultSize = 18,
    this.defaultExtSize = 14,
    this.otherMainSize = 16,
    this.bias = 0.3,
    this.lineGap = 36,
    this.inlineGap = 8,
    this.lyricAlign = LyricAlign.LEFT,
    this.lyricBaseLine = LyricBaseLine.CENTER,
    this.highlight = false,
    this.highlightDirection = HighlightDirection.LTR,
  });

  CustomUI.clone(CustomUI uiNetease)
    : this(
        defaultSize: uiNetease.defaultSize,
        defaultExtSize: uiNetease.defaultExtSize,
        otherMainSize: uiNetease.otherMainSize,
        bias: uiNetease.bias,
        lineGap: uiNetease.lineGap,
        inlineGap: uiNetease.inlineGap,
        lyricAlign: uiNetease.lyricAlign,
        lyricBaseLine: uiNetease.lyricBaseLine,
        highlight: uiNetease.highlight,
        highlightDirection: uiNetease.highlightDirection,
      );

  @override
  TextStyle getPlayingExtTextStyle() =>
      activeTextStyle?.copyWith(fontSize: extTextStyle?.fontSize) ??
      extTextStyle ??
      TextStyle(color: Colors.grey[300], fontSize: defaultExtSize);

  @override
  TextStyle getOtherExtTextStyle() => highlight && highlightColor != null
      ? extTextStyle != null
            ? extTextStyle!
            : TextStyle(color: Colors.white, fontSize: defaultSize)
      : extTextStyle ??
            TextStyle(color: Colors.white, fontSize: defaultExtSize);

  @override
  TextStyle getOtherMainTextStyle() =>
      textStyle ?? TextStyle(color: Colors.grey[200], fontSize: otherMainSize);

  @override
  TextStyle getPlayingMainTextStyle() => highlight && highlightColor != null
      ? textStyle != null
            ? textStyle!.copyWith(fontSize: activeTextStyle?.fontSize)
            : TextStyle(color: Colors.white, fontSize: defaultSize)
      : activeTextStyle ??
            TextStyle(color: Colors.white, fontSize: defaultSize);

  @override
  ValueKey? getKey() => key;

  @override
  double getInlineSpace() => inlineGap;

  @override
  double getLineSpace() => lineGap;

  @override
  double getPlayingLineBias() => bias;

  @override
  LyricAlign getLyricHorizontalAlign() => lyricAlign;

  @override
  LyricBaseLine getBiasBaseLine() => lyricBaseLine;

  @override
  bool enableHighlight() => highlight;

  @override
  HighlightDirection getHighlightDirection() => highlightDirection;

  @override
  Color getLyricHighlightColor() => highlightColor ?? AppTheme.primaryColor;
}
