import 'package:flutter/material.dart';
import 'package:flutter_lyric/core/lyric_style.dart';

class PlayLyricStyle {
  static LyricStyle default1 = LyricStyle(
    activeHighlightExtraFadeWidth: 40,
    textStyle: TextStyle(fontSize: 14, color: Colors.white70),
    activeStyle: TextStyle(fontSize: 16, color: Colors.white),
    translationStyle: TextStyle(fontSize: 12, color: Colors.white70),
    lineTextAlign: TextAlign.left,
    lineGap: 26,
    translationLineGap: 10,
    contentAlignment: CrossAxisAlignment.start,
    contentPadding: EdgeInsets.only(top: 200),
    selectionAnchorPosition: 0.48,
    fadeRange: FadeRange(top: 80, bottom: 80),
    selectedColor: Colors.white,
    selectedTranslationColor: Colors.white,
    scrollCurve: Curves.easeInOutSine,
    scrollDuration: Duration(milliseconds: 240),
    scrollDurations: {
      100: Duration(milliseconds: 200),  // 小距离
      300: Duration(milliseconds: 350),  // 中等距离
      500: Duration(milliseconds: 500),  // 大距离
      1000: Duration(milliseconds: 700), // 超大距离
    },
    enableSwitchAnimation: false,
    selectionAutoResumeMode: SelectionAutoResumeMode.selecting,
    selectionAutoResumeDuration: Duration(milliseconds: 320),
    activeAutoResumeDuration: Duration(milliseconds: 3000),
    activeHighlightColor: Colors.yellow,
    switchEnterDuration: Duration(milliseconds: 300),
    switchExitDuration: Duration(milliseconds: 500),
    switchEnterCurve: Curves.easeOutBack,
    switchExitCurve: Curves.easeOutQuint,
    selectionAlignment: MainAxisAlignment.center,
  );
}
