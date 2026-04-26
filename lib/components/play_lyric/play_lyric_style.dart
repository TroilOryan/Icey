import 'package:flutter/material.dart';
import 'package:flutter_lyric/core/lyric_style.dart';

class PlayLyricStyle {
  static LyricStyle default1 = LyricStyle(
    activeHighlightExtraFadeWidth: 40,
    textStyle: const TextStyle(fontSize: 14, color: Colors.white70),
    activeStyle: const TextStyle(fontSize: 16, color: Colors.white),
    translationStyle: const TextStyle(fontSize: 12, color: Colors.white70),
    lineTextAlign: TextAlign.left,
    lineGap: 26,
    translationLineGap: 10,
    contentAlignment: CrossAxisAlignment.start,
    contentPadding: const EdgeInsets.only(top: 200),
    selectionAnchorPosition: 0.5,
    activeAnchorPosition: 120,
    fadeRange: FadeRange(top: 80, bottom: 80),
    selectedColor: Colors.white,
    selectedTranslationColor: Colors.white,
    scrollCurve: Curves.easeInOutSine,
    scrollDuration: const Duration(milliseconds: 800),
    scrollDurations: {
      100: const Duration(milliseconds: 800), // 小距离
      300: const Duration(milliseconds: 850), // 中等距离
      500: const Duration(milliseconds: 900), // 大距离
      1000: const Duration(milliseconds: 950), // 超大距离
    },
    enableSwitchAnimation: false,
    selectionAutoResumeMode: SelectionAutoResumeMode.selecting,
    selectionAutoResumeDuration: const Duration(milliseconds: 320),
    activeAutoResumeDuration: const Duration(milliseconds: 3000),
    activeHighlightColor: Colors.yellow,
    switchEnterCurve: Curves.easeInOutSine,
    switchExitCurve: Curves.easeInOutSine,
    selectionAlignment: MainAxisAlignment.center,
  );

  /// 横屏样式 - 当前歌词居中
  static LyricStyle landscape(LyricStyle base) => LyricStyle(
    activeHighlightExtraFadeWidth: base.activeHighlightExtraFadeWidth,
    textStyle: base.textStyle,
    activeStyle: base.activeStyle,
    translationStyle: base.translationStyle,
    lineTextAlign: base.lineTextAlign,
    lineGap: base.lineGap,
    translationLineGap: base.translationLineGap,
    contentAlignment: base.contentAlignment,
    contentPadding: base.contentPadding,
    selectionAnchorPosition: base.selectionAnchorPosition,
    activeAnchorPosition: 0.5,
    fadeRange: base.fadeRange,
    selectedColor: base.selectedColor,
    selectedTranslationColor: base.selectedTranslationColor,
    scrollCurve: base.scrollCurve,
    scrollDuration: base.scrollDuration,
    scrollDurations: base.scrollDurations,
    enableSwitchAnimation: base.enableSwitchAnimation,
    selectionAutoResumeMode: base.selectionAutoResumeMode,
    selectionAutoResumeDuration: base.selectionAutoResumeDuration,
    activeAutoResumeDuration: base.activeAutoResumeDuration,
    activeHighlightColor: base.activeHighlightColor,
    activeHighlightGradient: base.activeHighlightGradient,
    switchEnterCurve: base.switchEnterCurve,
    switchExitCurve: base.switchExitCurve,
    selectionAlignment: base.selectionAlignment,
  );
}
