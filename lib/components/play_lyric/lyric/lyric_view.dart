import 'dart:async';
import 'package:flutter/material.dart';
import './lyric_model.dart';
import 'lyric_line_widget.dart';

/// Apple Music风格歌词视图
/// 支持逐字高亮、翻译显示、平滑滚动动画、边缘模糊效果
class LyricView extends StatefulWidget {
  /// 歌词数据
  final Lyrics lyrics;
  
  /// 当前播放时间
  final Duration currentTime;
  
  /// 是否显示翻译
  final bool showTranslation;
  
  /// 是否启用自动滚动
  final bool autoScroll;
  
  /// 滚动动画时长
  final Duration scrollDuration;
  
  /// 滚动曲线
  final Curve scrollCurve;
  
  /// 当前播放行距离视口顶部的像素值
  final double activeLineTopOffset;
  
  /// 基础文本样式
  final TextStyle? baseStyle;
  
  /// 高亮文本样式
  final TextStyle? highlightStyle;
  
  /// 翻译文本样式
  final TextStyle? translationStyle;
  
  /// 翻译高亮样式
  final TextStyle? translationHighlightStyle;
  
  /// 行间距
  final double lineSpacing;
  
  /// 点击行回调
  final void Function(int index, LyricLine line)? onLineTap;
  
  /// 模糊程度 (0.0 - 10.0)
  final double blurSigma;
  
  /// 是否启用模糊效果
  final bool enableBlur;
  
  /// 边缘模糊遮罩高度
  final double edgeBlurHeight;
  
  /// 是否启用边缘模糊
  final bool enableEdgeBlur;

  const LyricView({
    super.key,
    required this.lyrics,
    required this.currentTime,
    this.showTranslation = true,
    this.autoScroll = true,
    this.scrollDuration = const Duration(milliseconds: 400),
    this.scrollCurve = Curves.easeOutCubic,
    this.activeLineTopOffset = 150,
    this.baseStyle,
    this.highlightStyle,
    this.translationStyle,
    this.translationHighlightStyle,
    this.lineSpacing = 16,
    this.onLineTap,
    this.blurSigma = 3.0,
    this.enableBlur = true,
    this.edgeBlurHeight = 100,
    this.enableEdgeBlur = true,
  });

  @override
  State<LyricView> createState() => _LyricViewState();
}

class _LyricViewState extends State<LyricView> {
  final ScrollController _scrollController = ScrollController();
  int _currentLineIndex = -1;
  bool _isUserDragging = false;
  Timer? _dragTimer;
  final Map<int, double> _lineHeights = {};
  final List<GlobalKey> _lineKeys = [];
  
  /// 默认行高估计值
  static const double _defaultLineHeight = 70.0;

  @override
  void initState() {
    super.initState();
    _initLineKeys();
    _currentLineIndex = widget.lyrics.getActiveLineIndex(widget.currentTime);
    
    // 首帧后滚动到正确位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentLineIndex >= 0) {
        _scrollToLine(_currentLineIndex, animate: false);
      }
    });
  }
  
  @override
  void didUpdateWidget(LyricView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.lyrics != widget.lyrics) {
      _initLineKeys();
      _lineHeights.clear();
    }
    
    _updateCurrentLine();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _dragTimer?.cancel();
    super.dispose();
  }
  
  void _initLineKeys() {
    _lineKeys.clear();
    for (int i = 0; i < widget.lyrics.lines.length; i++) {
      _lineKeys.add(GlobalKey());
    }
  }
  
  void _updateCurrentLine() {
    final newIndex = widget.lyrics.getActiveLineIndex(widget.currentTime);
    
    if (newIndex != _currentLineIndex) {
      _currentLineIndex = newIndex;
      
      if (widget.autoScroll && !_isUserDragging && newIndex >= 0) {
        _scrollToLine(newIndex);
      }
    }
  }
  
  /// 滚动到指定行
  void _scrollToLine(int index, {bool animate = true}) {
    if (!_scrollController.hasClients) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      
      // 计算目标行在列表中的位置
      double lineTop = 0;
      for (int i = 0; i < index; i++) {
        lineTop += _getLineHeight(i) + widget.lineSpacing;
      }
      
      // 当前行的中心位置
      final lineCenter = lineTop + _getLineHeight(index) / 2;
      
      // 目标滚动位置：让行中心距离视口顶部 activeLineTopOffset 像素
      final targetOffset = lineCenter - widget.activeLineTopOffset;
      
      // 限制在有效范围内
      final maxOffset = _scrollController.position.maxScrollExtent;
      final clampedOffset = targetOffset.clamp(0.0, maxOffset);
      
      if (animate) {
        _scrollController.animateTo(
          clampedOffset,
          duration: widget.scrollDuration,
          curve: widget.scrollCurve,
        );
      } else {
        _scrollController.jumpTo(clampedOffset);
      }
    });
  }
  
  double _getLineHeight(int index) {
    if (_lineHeights.containsKey(index)) {
      return _lineHeights[index]!;
    }
    
    if (index < _lineKeys.length) {
      final key = _lineKeys[index];
      final context = key.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final height = renderBox.size.height;
          _lineHeights[index] = height;
          return height;
        }
      }
    }
    return _defaultLineHeight;
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.lyrics.isEmpty) {
      return _buildEmptyState();
    }
    
    // 计算足够的上下留白
    final topPadding = widget.activeLineTopOffset + 100;
    final bottomPadding = 400.0;
    
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification) {
              if (notification.dragDetails != null) {
                _isUserDragging = true;
                _dragTimer?.cancel();
              }
            } else if (notification is ScrollEndNotification) {
              _dragTimer?.cancel();
              _dragTimer = Timer(const Duration(seconds: 3), () {
                if (mounted) {
                  setState(() {
                    _isUserDragging = false;
                  });
                  if (_currentLineIndex >= 0) {
                    _scrollToLine(_currentLineIndex);
                  }
                }
              });
            }
            return false;
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
            itemCount: widget.lyrics.lines.length,
            itemBuilder: (context, index) {
              final line = widget.lyrics.lines[index];
              final isActive = index == _currentLineIndex;
              
              return GestureDetector(
                key: index < _lineKeys.length ? _lineKeys[index] : null,
                onTap: () => widget.onLineTap?.call(index, line),
                behavior: HitTestBehavior.translucent,
                child: Padding(
                  padding: EdgeInsets.only(bottom: widget.lineSpacing),
                  child: LyricLineWidget(
                    lyricLine: line,
                    currentTime: widget.currentTime,
                    isActive: isActive,
                    showTranslation: widget.showTranslation,
                    baseStyle: widget.baseStyle,
                    highlightStyle: widget.highlightStyle,
                    translationStyle: widget.translationStyle,
                    translationHighlightStyle: widget.translationHighlightStyle,
                    blurSigma: widget.blurSigma,
                    enableBlur: widget.enableBlur,
                  ),
                ),
              );
            },
          ),
        ),
        
        // 顶部边缘模糊
        if (widget.enableEdgeBlur)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: widget.edgeBlurHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(1.0),
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ),
        
        // 底部边缘模糊
        if (widget.enableEdgeBlur)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: widget.edgeBlurHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(1.0),
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.music_note_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无歌词',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// 歌词视图控制器
class LyricViewController {
  _LyricViewState? _state;
  
  void scrollToLine(int index) {
    _state?._scrollToLine(index);
  }
  
  void resumeAutoScroll() {
    if (_state != null) {
      _state!._isUserDragging = false;
      if (_state!._currentLineIndex >= 0) {
        _state!._scrollToLine(_state!._currentLineIndex);
      }
    }
  }
  
  void pauseAutoScroll() {
    if (_state != null) {
      _state!._isUserDragging = true;
    }
  }
}
