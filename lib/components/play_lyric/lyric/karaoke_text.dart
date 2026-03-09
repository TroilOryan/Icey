import 'dart:ui';
import 'package:flutter/material.dart';
import './lyric_model.dart';

/// 逐字卡拉OK文本组件
/// 实现Apple Music风格的逐字高亮效果
class KaraokeText extends StatefulWidget {
  /// 歌词行数据
  final LyricLine lyricLine;
  
  /// 当前播放时间
  final Duration currentTime;
  
  /// 基础文本样式
  final TextStyle baseStyle;
  
  /// 高亮文本样式
  final TextStyle highlightStyle;
  
  /// 文本对齐方式
  final TextAlign textAlign;
  
  /// 是否启用模糊过渡效果
  final bool enableBlurEffect;

  const KaraokeText({
    super.key,
    required this.lyricLine,
    required this.currentTime,
    required this.baseStyle,
    required this.highlightStyle,
    this.textAlign = TextAlign.center,
    this.enableBlurEffect = true,
  });

  @override
  State<KaraokeText> createState() => _KaraokeTextState();
}

class _KaraokeTextState extends State<KaraokeText> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }
  
  @override
  void didUpdateWidget(KaraokeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当时间变化时触发动画更新
    if (oldWidget.currentTime != widget.currentTime) {
      _animationController.forward(from: 0);
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 如果没有逐字信息，使用整行高亮
    if (!widget.lyricLine.hasWords) {
      return _buildSimpleHighlightText();
    }
    
    return _buildWordByWordText();
  }
  
  /// 构建简单整行高亮文本（无逐字信息时）
  Widget _buildSimpleHighlightText() {
    final progress = widget.lyricLine.getProgress(widget.currentTime);
    final text = widget.lyricLine.text;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // 底层：未高亮文本
            Text(
              text,
              style: widget.baseStyle,
              textAlign: widget.textAlign,
            ),
            // 顶层：高亮文本（裁剪显示）
            ClipRect(
              clipper: _ProgressClipper(progress),
              child: Text(
                text,
                style: widget.highlightStyle,
                textAlign: widget.textAlign,
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// 构建逐字高亮文本
  Widget _buildWordByWordText() {
    final words = widget.lyricLine.words!;
    final spans = <InlineSpan>[];
    
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final wordProgress = word.getProgress(widget.currentTime);
      final isActive = word.isActive(widget.currentTime);
      final isCompleted = word.isCompleted(widget.currentTime);
      
      // 计算当前字的高亮程度
      double highlightProgress = 0.0;
      if (isCompleted) {
        highlightProgress = 1.0;
      } else if (isActive) {
        highlightProgress = wordProgress.clamp(0.0, 1.0);
      }
      
      // 创建带有高亮效果的文本跨度
      spans.add(_buildWordSpan(word.text, highlightProgress, isActive));
    }
    
    return RichText(
      text: TextSpan(children: spans),
      textAlign: widget.textAlign,
    );
  }
  
  /// 构建单个字的文本跨度
  InlineSpan _buildWordSpan(String text, double progress, bool isActive) {
    // 使用Shader实现渐变高亮效果
    final baseColor = widget.baseStyle.color ?? Colors.white54;
    final highlightColor = widget.highlightStyle.color ?? Colors.white;
    
    // 插值计算颜色
    final color = Color.lerp(baseColor, highlightColor, progress);
    
    // 根据进度调整字重和大小，实现Apple Music的"膨胀"效果
    final fontSize = widget.baseStyle.fontSize ?? 24.0;
    final fontWeight = widget.baseStyle.fontWeight ?? FontWeight.normal;
    final highlightFontWeight = widget.highlightStyle.fontWeight ?? FontWeight.bold;
    
    // 活跃状态下轻微放大
    final currentFontSize = isActive 
        ? fontSize + (fontSize * 0.02 * progress)
        : fontSize;
    
    final currentFontWeight = FontWeight.lerp(
      fontWeight, 
      highlightFontWeight, 
      progress,
    );
    
    return TextSpan(
      text: text,
      style: (widget.baseStyle.copyWith(
        color: color,
        fontSize: currentFontSize,
        fontWeight: currentFontWeight,
        // 添加轻微的阴影效果增强立体感
        shadows: progress > 0
            ? [
                Shadow(
                  color: highlightColor.withOpacity(0.3 * progress),
                  blurRadius: 8 * progress,
                ),
              ]
            : null,
      )),
    );
  }
}

/// 进度裁剪器
class _ProgressClipper extends CustomClipper<Rect> {
  final double progress;
  
  _ProgressClipper(this.progress);
  
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * progress, size.height);
  }
  
  @override
  bool shouldReclip(covariant _ProgressClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

/// 扩展方法：判断Duration是否相等
extension DurationExtension on Duration {
  bool equals(Duration other) {
    return inMilliseconds == other.inMilliseconds;
  }
}
