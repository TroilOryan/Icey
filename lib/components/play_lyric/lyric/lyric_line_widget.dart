import 'dart:ui';
import 'package:flutter/material.dart';
import './lyric_model.dart';
import 'karaoke_text.dart';

/// 单行歌词组件
/// 包含主歌词、翻译歌词、高亮动画效果和模糊效果
class LyricLineWidget extends StatelessWidget {
  /// 歌词行数据
  final LyricLine lyricLine;
  
  /// 当前播放时间
  final Duration currentTime;
  
  /// 是否为当前播放行
  final bool isActive;
  
  /// 是否显示翻译
  final bool showTranslation;
  
  /// 基础文本样式
  final TextStyle? baseStyle;
  
  /// 高亮文本样式
  final TextStyle? highlightStyle;
  
  /// 翻译文本样式
  final TextStyle? translationStyle;
  
  /// 翻译高亮样式
  final TextStyle? translationHighlightStyle;
  
  /// 行内边距
  final EdgeInsets padding;
  
  /// 文本对齐方式
  final TextAlign textAlign;
  
  /// 模糊程度 (0.0 - 10.0)
  final double blurSigma;
  
  /// 是否启用模糊效果（非当前播放行模糊）
  final bool enableBlur;

  const LyricLineWidget({
    super.key,
    required this.lyricLine,
    required this.currentTime,
    this.isActive = false,
    this.showTranslation = true,
    this.baseStyle,
    this.highlightStyle,
    this.translationStyle,
    this.translationHighlightStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    this.textAlign = TextAlign.center,
    this.blurSigma = 3.0,
    this.enableBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    // 获取默认样式
    final defaultBaseStyle = baseStyle ?? _getDefaultBaseStyle(context);
    final defaultHighlightStyle = highlightStyle ?? _getDefaultHighlightStyle(context);
    final defaultTranslationStyle = translationStyle ?? _getDefaultTranslationStyle(context);
    final defaultTranslationHighlightStyle = 
        translationHighlightStyle ?? _getDefaultTranslationHighlightStyle(context);
    
    // 当前播放行清晰，其他行模糊
    final shouldBlur = enableBlur && !isActive;
    
    // 透明度和缩放
    final opacity = isActive ? 1.0 : 0.5;
    final scale = isActive ? 1.0 : 0.95;
    
    Widget content = AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: opacity,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: scale,
        curve: Curves.easeOutCubic,
        child: Container(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 主歌词
              _buildMainLyric(
                defaultBaseStyle, 
                defaultHighlightStyle,
              ),
              
              // 翻译歌词（如果有且开启显示）
              if (showTranslation && lyricLine.hasTranslation)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _buildTranslation(
                    defaultTranslationStyle,
                    defaultTranslationHighlightStyle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    
    // 如果需要模糊效果，包装一层模糊滤镜
    if (shouldBlur) {
      return ClipRRect(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: blurSigma,
            sigmaY: blurSigma,
            tileMode: TileMode.decal,
          ),
          child: content,
        ),
      );
    }
    
    return content;
  }
  
  /// 构建主歌词
  Widget _buildMainLyric(TextStyle baseStyle, TextStyle highlightStyle) {
    // 如果有逐字信息，使用逐字高亮
    if (lyricLine.hasWords) {
      return KaraokeText(
        lyricLine: lyricLine,
        currentTime: currentTime,
        baseStyle: baseStyle,
        highlightStyle: highlightStyle,
        textAlign: textAlign,
      );
    }
    
    // 否则使用整行高亮
    final progress = lyricLine.getProgress(currentTime);
    
    return _buildHighlightText(
      text: lyricLine.text,
      progress: isActive ? progress : 0.0,
      baseStyle: baseStyle,
      highlightStyle: highlightStyle,
    );
  }
  
  /// 构建翻译歌词
  Widget _buildTranslation(TextStyle baseStyle, TextStyle highlightStyle) {
    // 翻译不支持逐字，使用整行高亮
    final progress = isActive ? lyricLine.getProgress(currentTime) : 0.0;
    
    return _buildHighlightText(
      text: lyricLine.translation!,
      progress: progress,
      baseStyle: baseStyle,
      highlightStyle: highlightStyle,
    );
  }
  
  /// 构建高亮文本
  Widget _buildHighlightText({
    required String text,
    required double progress,
    required TextStyle baseStyle,
    required TextStyle highlightStyle,
  }) {
    return Stack(
      children: [
        // 底层：未高亮文本
        Text(
          text,
          style: baseStyle,
          textAlign: textAlign,
        ),
        // 顶层：高亮文本
        if (progress > 0)
          ClipRect(
            clipper: _TextProgressClipper(progress),
            child: Text(
              text,
              style: highlightStyle,
              textAlign: textAlign,
            ),
          ),
      ],
    );
  }
  
  /// 获取默认基础样式
  TextStyle _getDefaultBaseStyle(BuildContext context) {
    return TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: Colors.white.withOpacity(0.5),
      height: 1.4,
    );
  }
  
  /// 获取默认高亮样式
  TextStyle _getDefaultHighlightStyle(BuildContext context) {
    return const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      height: 1.4,
    );
  }
  
  /// 获取默认翻译样式
  TextStyle _getDefaultTranslationStyle(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.white.withOpacity(0.4),
      height: 1.3,
    );
  }
  
  /// 获取默认翻译高亮样式
  TextStyle _getDefaultTranslationHighlightStyle(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white.withOpacity(0.85),
      height: 1.3,
    );
  }
}

/// 文本进度裁剪器
class _TextProgressClipper extends CustomClipper<Rect> {
  final double progress;
  
  _TextProgressClipper(this.progress);
  
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * progress, size.height);
  }
  
  @override
  bool shouldReclip(covariant _TextProgressClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}
