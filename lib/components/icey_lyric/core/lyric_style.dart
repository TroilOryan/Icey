import 'package:flutter/widgets.dart';

/// 选中行自动恢复模式
enum SelectionAutoResumeMode {
  /// 选择中实时恢复
  selecting,

  /// 停止选择后再恢复
  afterSelecting,

  /// 不恢复
  neverResume,
}

class LyricStyle {
  // ==================== 文本样式相关 ====================

  /// 普通行文本样式
  final TextStyle textStyle;

  /// 高亮行文本样式（播放行）
  final TextStyle activeStyle;

  /// 翻译行文本样式
  final TextStyle translationStyle;

  /// 翻译行高亮颜色
  final Color? translationActiveColor;

  // ==================== 布局相关 ====================

  /// 文本对齐方式
  final TextAlign lineTextAlign;

  /// 交叉轴对齐方式
  final CrossAxisAlignment contentAlignment;

  /// 内容内边距
  final EdgeInsets contentPadding;

  /// 行间距
  final double lineGap;

  /// 翻译行间距
  final double translationLineGap;

  // ==================== 锚点定位相关 ====================

  /// 选中锚点位置（0-1 为相对位置，>1 为绝对像素值）
  final double selectionAnchorPosition;

  /// 选中锚点对齐方式
  final MainAxisAlignment selectionAlignment;

  /// 播放锚点位置（0-1 为相对位置，>1 为绝对像素值）
  final double activeAnchorPosition;

  /// 播放锚点对齐方式
  final MainAxisAlignment activeAlignment;

  // ==================== 选中状态相关 ====================

  /// 选中行字体颜色
  final Color selectedColor;

  /// 选中翻译行字体颜色
  final Color selectedTranslationColor;

  // ==================== 高亮效果相关 ====================

  /// 播放行高亮颜色
  final Color? activeHighlightColor;

  /// 播放行高亮渐变
  final LinearGradient? activeHighlightGradient;

  /// 高亮渐变末尾附加的渐隐宽度
  final double activeHighlightExtraFadeWidth;

  // ==================== 渐隐效果 ====================

  /// 上下渐隐范围
  final FadeRange? fadeRange;

  // ==================== 滚动动画相关 ====================

  /// 滚动动画时长
  final Duration scrollDuration;

  /// 滚动动画时长映射
  final Map<double, Duration> scrollDurations;

  /// 滚动动画曲线
  final Curve scrollCurve;

  // ==================== 自动恢复相关 ====================

  /// 选中行自动恢复时长
  final Duration selectionAutoResumeDuration;

  /// 播放行自动恢复时长
  final Duration activeAutoResumeDuration;

  /// 选中行自动恢复模式
  final SelectionAutoResumeMode selectionAutoResumeMode;

  // ==================== 切换动画相关 ====================

  /// 是否启用切换动画
  final bool enableSwitchAnimation;

  /// 切换进入动画时长
  final Duration switchEnterDuration;

  /// 切换退出动画时长
  final Duration switchExitDuration;

  /// 切换进入动画曲线
  final Curve switchEnterCurve;

  /// 切换退出动画曲线
  final Curve switchExitCurve;

  // ==================== 其他功能 ====================

  /// 是否只绘制播放行
  final bool activeLineOnly;

  /// 是否禁用触摸事件
  final bool disableTouchEvent;

  /// 渐隐范围是否为相对值
  bool get isFadeRelative => (fadeRange?.top ?? 0) <= 1;

  LyricStyle({
    required this.textStyle,
    required this.activeStyle,
    required this.translationStyle,
    required this.lineTextAlign,
    required this.lineGap,
    required this.contentAlignment,
    required this.translationLineGap,
    this.contentPadding = EdgeInsets.zero,
    required this.selectionAnchorPosition,
    this.fadeRange,
    required this.scrollDuration,
    required this.selectionAlignment,
    this.scrollDurations = const {},
    required this.selectedColor,
    required this.selectedTranslationColor,
    required this.selectionAutoResumeDuration,
    required this.activeAutoResumeDuration,
    this.selectionAutoResumeMode = SelectionAutoResumeMode.selecting,
    this.activeHighlightColor,
    this.enableSwitchAnimation = true,
    this.switchEnterDuration = const Duration(milliseconds: 200),
    this.switchExitDuration = const Duration(milliseconds: 200),
    this.switchEnterCurve = Curves.easeIn,
    this.switchExitCurve = Curves.easeOut,
    this.scrollCurve = Curves.easeOutCubic,
    this.translationActiveColor,
    this.disableTouchEvent = false,
    double? activeAnchorPosition,
    this.activeHighlightExtraFadeWidth = 0,
    this.activeHighlightGradient,
    MainAxisAlignment? activeAlignment,
    this.activeLineOnly = false,
  })  : activeAnchorPosition = activeAnchorPosition ?? selectionAnchorPosition,
        activeAlignment = activeAlignment ?? selectionAlignment,
        assert(selectionAutoResumeDuration < activeAutoResumeDuration,
            'selectLineResumeDuration must be less than activeLineResumeDuration');

  static const _unset = Object();

  LyricStyle copyWith({
    TextStyle? textStyle,
    TextStyle? activeStyle,
    TextStyle? translationStyle,
    TextAlign? textAlign,
    double? lineGap,
    CrossAxisAlignment? contentAlignment,
    double? translationLineGap,
    EdgeInsets? contentPadding,
    double? anchorPosition,
    FadeRange? fadeRange,
    Duration? scrollDuration,
    MainAxisAlignment? highlightAlign,
    Map<double, Duration>? scrollDurationMap,
    Duration? selectLineResumeDuration,
    Duration? activeLineResumeDuration,
    SelectionAutoResumeMode? selectLineResumeMode,
    Object? activeHighlightColor = _unset,
    bool? enableSwitchAnimation,
    Duration? switchEnterDuration,
    Duration? switchExitDuration,
    Curve? switchEnterCurve,
    Curve? switchExitCurve,
    Curve? scrollCurve,
    Object? translationActiveColor = _unset,
    Object? activeAnchorPosition = _unset,
    Color? selectedColor,
    Color? selectedTranslationColor,
    Object? activeAlignment = _unset,
    double? activeHighlightTailGradientWidth,
    Object? activeHighlightGradient = _unset,
    bool? activeLineOnly,
    bool? disableTouchEvent,
  }) {
    return LyricStyle(
      activeHighlightColor: activeHighlightColor == _unset
          ? this.activeHighlightColor
          : activeHighlightColor as Color?,
      textStyle: textStyle ?? this.textStyle,
      activeStyle: activeStyle ?? this.activeStyle,
      translationStyle: translationStyle ?? this.translationStyle,
      lineTextAlign: textAlign ?? lineTextAlign,
      lineGap: lineGap ?? this.lineGap,
      contentAlignment: contentAlignment ?? this.contentAlignment,
      translationLineGap: translationLineGap ?? this.translationLineGap,
      contentPadding: contentPadding ?? this.contentPadding,
      selectionAnchorPosition: anchorPosition ?? selectionAnchorPosition,
      activeAnchorPosition: activeAnchorPosition == _unset
          ? this.activeAnchorPosition
          : activeAnchorPosition as double?,
      fadeRange: fadeRange ?? this.fadeRange,
      scrollDuration: scrollDuration ?? this.scrollDuration,
      selectionAlignment: highlightAlign ?? selectionAlignment,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedTranslationColor:
          selectedTranslationColor ?? this.selectedTranslationColor,
      activeAlignment: activeAlignment == _unset
          ? this.activeAlignment
          : activeAlignment as MainAxisAlignment?,
      scrollDurations: scrollDurationMap ?? scrollDurations,
      selectionAutoResumeDuration:
          selectLineResumeDuration ?? selectionAutoResumeDuration,
      activeAutoResumeDuration:
          activeLineResumeDuration ?? activeAutoResumeDuration,
      selectionAutoResumeMode: selectLineResumeMode ?? selectionAutoResumeMode,
      enableSwitchAnimation:
          enableSwitchAnimation ?? this.enableSwitchAnimation,
      switchEnterDuration: switchEnterDuration ?? this.switchEnterDuration,
      switchExitDuration: switchExitDuration ?? this.switchExitDuration,
      switchEnterCurve: switchEnterCurve ?? this.switchEnterCurve,
      switchExitCurve: switchExitCurve ?? this.switchExitCurve,
      scrollCurve: scrollCurve ?? this.scrollCurve,
      translationActiveColor: translationActiveColor == _unset
          ? this.translationActiveColor
          : translationActiveColor as Color?,
      activeHighlightExtraFadeWidth:
          activeHighlightTailGradientWidth ?? activeHighlightExtraFadeWidth,
      activeHighlightGradient: activeHighlightGradient == _unset
          ? this.activeHighlightGradient
          : activeHighlightGradient as LinearGradient?,
      activeLineOnly: activeLineOnly ?? this.activeLineOnly,
      disableTouchEvent: disableTouchEvent ?? this.disableTouchEvent,
    );
  }

  /// 计算选中锚点位置
  double calcSelectionAnchorPosition(double viewHeight) {
    return selectionAnchorPosition <= 1
        ? viewHeight * selectionAnchorPosition
        : selectionAnchorPosition;
  }

  /// 计算播放锚点位置
  double calcActiveAnchorPosition(double viewHeight) {
    return activeAnchorPosition <= 1
        ? viewHeight * activeAnchorPosition
        : activeAnchorPosition;
  }

  RenderComparison compareTo(LyricStyle other) {
    if (identical(this, other)) {
      return RenderComparison.identical;
    }
    if (lineGap != other.lineGap ||
        contentPadding != other.contentPadding ||
        translationLineGap != other.translationLineGap) {
      return RenderComparison.layout;
    }
    final styles = [textStyle, translationStyle, activeStyle];
    final otherStyles = [
      other.textStyle,
      other.translationStyle,
      other.activeStyle
    ];
    for (var i = 0; i < styles.length; i++) {
      final element = styles[i];
      final otherElement = otherStyles[i];
      if (element.compareTo(otherElement) != RenderComparison.identical) {
        return element.compareTo(otherElement);
      }
    }
    return RenderComparison.identical;
  }
}

/// 渐隐范围
class FadeRange {
  /// 顶部渐隐值
  final double top;

  /// 底部渐隐值
  final double bottom;

  FadeRange({required this.top, required this.bottom});

  FadeRange copyWith({double? top, double? bottom}) {
    return FadeRange(top: top ?? this.top, bottom: bottom ?? this.bottom);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FadeRange) return false;
    return top == other.top && bottom == other.bottom;
  }

  @override
  int get hashCode => top.hashCode ^ bottom.hashCode;
}
