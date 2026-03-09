import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import './lyric_model.dart';
import 'lyric_line_widget.dart';

/// 高级歌词视图
class AdvancedLyricView extends StatefulWidget {
  final Lyrics lyrics;
  final Duration currentTime;
  final bool showTranslation;
  final bool autoScroll;
  final Duration scrollDuration;
  final Curve scrollCurve;
  final double activeLineTopOffset;
  final TextStyle? baseStyle;
  final TextStyle? highlightStyle;
  final TextStyle? translationStyle;
  final TextStyle? translationHighlightStyle;
  final double lineSpacing;
  final bool enableEdgeBlur;
  final double edgeBlurHeight;
  final void Function(int index, LyricLine line)? onLineTap;
  final double blurSigma;
  final bool enableBlur;

  const AdvancedLyricView({
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
    this.lineSpacing = 20,
    this.enableEdgeBlur = true,
    this.edgeBlurHeight = 120,
    this.onLineTap,
    this.blurSigma = 3.0,
    this.enableBlur = true,
  });

  @override
  State<AdvancedLyricView> createState() => _AdvancedLyricViewState();
}

class _AdvancedLyricViewState extends State<AdvancedLyricView> {
  final ScrollController _scrollController = ScrollController();
  int _currentLineIndex = -1;
  bool _isUserDragging = false;
  Timer? _dragTimer;
  final Map<int, double> _lineHeights = {};
  final List<GlobalKey> _lineKeys = [];
  static const double _defaultLineHeight = 70.0;

  @override
  void initState() {
    super.initState();
    _initLineKeys();
    _currentLineIndex = widget.lyrics.getActiveLineIndex(widget.currentTime);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentLineIndex >= 0) {
        _scrollToLine(_currentLineIndex, animate: false);
      }
    });
  }

  @override
  void didUpdateWidget(AdvancedLyricView oldWidget) {
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

  void _scrollToLine(int index, {bool animate = true}) {
    if (!_scrollController.hasClients) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      
      double lineTop = 0;
      for (int i = 0; i < index; i++) {
        lineTop += _getLineHeight(i) + widget.lineSpacing;
      }
      
      final lineCenter = lineTop + _getLineHeight(index) / 2;
      final targetOffset = lineCenter - widget.activeLineTopOffset;
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

    final topPadding = widget.activeLineTopOffset + 100;
    final bottomPadding = 400.0;

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification) {
              if (notification.dragDetails != null) {
                _isUserDragging = true;
              }
            } else if (notification is ScrollEndNotification) {
              _dragTimer?.cancel();
              _dragTimer = Timer(const Duration(seconds: 3), () {
                if (mounted) {
                  setState(() => _isUserDragging = false);
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
