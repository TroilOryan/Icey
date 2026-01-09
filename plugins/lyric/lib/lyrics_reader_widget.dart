import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lyric/lyric_ui/lyric_ui.dart';
import 'package:lyric/lyric_ui/ui_netease.dart';
import 'package:lyric/lyrics_log.dart';
import 'package:lyric/lyrics_reader_model.dart';
import 'package:lyric/lyrics_reader_paint.dart';

///SelectLineBuilder
///[int] is select progress
///[VoidCallback] call VoidCallback.call(),select current
typedef SelectLineBuilder = Widget Function(int, VoidCallback);
typedef EmptyBuilder = Widget? Function();

extension FunctionExt on Function {
  VoidCallback debounce({int? timeout}) {
    return FunctionProxy(this, timeout: timeout).debounce;
  }
}

class FunctionProxy {
  static final Map<String, Timer> _funcDebounce = {};
  final Function? target;

  final int timeout;

  FunctionProxy(this.target, {int? timeout}) : timeout = timeout ?? 500;

  void debounce() {
    String key = hashCode.toString();
    Timer? timer = _funcDebounce[key];
    timer?.cancel();
    timer = Timer(Duration(milliseconds: timeout), () {
      Timer? t = _funcDebounce.remove(key);
      t?.cancel();
      target?.call();
    });
    _funcDebounce[key] = timer;
  }
}

///Lyrics Reader Widget
///[size] config widget size,default is screenWidth,screenWidth
///[ui]  config lyric style
///[position] music progress,unit is millisecond
///[selectLineBuilder] call select line widget
///[playing] if playing status is null,no highlight.
///
class LyricsReader extends StatefulWidget {
  final Size? size;
  final LyricsReaderModel? model;
  final LyricUI lyricUI;
  final bool? playing;
  final bool blur;
  final int position;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Function(int)? onLineTap;
  final VoidCallback? onScroll;
  final SelectLineBuilder? selectLineBuilder;
  final EmptyBuilder? emptyBuilder;

  const LyricsReader({
    this.blur = true,
    this.position = 0,
    this.model,
    this.padding,
    this.size,
    this.selectLineBuilder,
    required this.lyricUI,
    this.onTap,
    this.onLineTap,
    this.onScroll,
    this.playing,
    this.emptyBuilder,
  });

  @override
  State<StatefulWidget> createState() => LyricReaderState();
}

class LyricReaderState extends State<LyricsReader>
    with TickerProviderStateMixin {
  late LyricsReaderPaint lyricPaint;

  StreamController<int> centerLyricIndexStream = StreamController.broadcast();
  AnimationController? _flingController;
  AnimationController? _highlightController;
  AnimationController? _lineController;

  Timer? waitTimer;

  Size canvasSize = Size.infinite;

  bool isDrag = false;

  /// 等待恢复
  bool isWait = false;

  ///缓存下lineIndex避免重复获取
  int cacheLine = -1;

  BoxConstraints? cacheBox;

  bool isShowSelectLineWidget = false;

  ///show select line
  void setSelectLine(bool isShow) {
    if (!mounted) return;
    setState(() {
      isShowSelectLineWidget = isShow;
    });
  }

  void selectLineAndScrollToPlayLine([bool animation = true]) {
    selectLine(widget.model?.getCurrentLine(widget.position) ?? 0);

    if (cacheLine != lyricPaint.playingIndex) {
      lyricPaint.highlightWidth = 0;
      cacheLine = lyricPaint.playingIndex;
      scrollToPlayLine(animation);
    }
  }

  ///select current play line
  void scrollToPlayLine([bool animation = true]) {
    safeLyricOffset(
        widget.model?.computeScroll(lyricPaint.playingIndex,
                lyricPaint.playingIndex, widget.lyricUI) ??
            0,
        animation);
  }

  void selectLine(int line) {
    lyricPaint.playingIndex = line;
  }

  ///update progress after verify
  void safeLyricOffset(double offset, [bool animation = true]) {
    if (isDrag || isWait || _flingController?.isAnimating == true) return;

    realUpdateOffset(offset, animation);
  }

  void realUpdateOffset(double offset, [bool animation = true]) {
    if (widget.lyricUI.enableLineAnimation() && animation) {
      animationOffset(offset);
    } else {
      lyricPaint.lyricOffset = offset;
    }
  }

  ///update progress use animation
  void animationOffset(double offset) {
    disposeLine();
    _lineController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    final Animation animate = Tween<double>(
      begin: lyricPaint.lyricOffset,
      end: offset,
    ).chain(CurveTween(curve: Curves.easeInOutSine)).animate(_lineController!)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          disposeLine();
        }
      });

    animate.addListener(() {
      lyricPaint.lyricOffset = animate.value.clamp(lyricPaint.maxOffset, 0);
    });

    _lineController?.forward();
  }

  ///calculate all line draw info
  void refreshLyricHeight(Size size) {
    lyricPaint.clearCache();
    widget.model?.lyrics.forEach((element) {
      final LyricDrawInfo drawInfo = LyricDrawInfo()
        ..playingExtTextPainter = getTextPaint(
            element.extText, widget.lyricUI.getPlayingExtTextStyle(),
            size: size)
        ..otherExtTextPainter = getTextPaint(
            element.extText, widget.lyricUI.getOtherExtTextStyle(),
            size: size)
        ..playingMainTextPainter = getTextPaint(
            element.mainText, widget.lyricUI.getPlayingMainTextStyle(),
            size: size)
        ..otherMainTextPainter = getTextPaint(
            element.mainText, widget.lyricUI.getOtherMainTextStyle(),
            size: size);

      if (widget.lyricUI.enableHighlight()) {
        setTextInlineInfo(drawInfo, widget.lyricUI, element.mainText!);
        setTextSpanDrawInfo(
            widget.lyricUI,
            element.spanList ?? element.defaultSpanList,
            TextPainter(
              textDirection: TextDirection.ltr,
            ));
      }
      element.drawInfo = drawInfo;
    });
  }

  /// 获取文本高度
  TextPainter getTextPaint(String? text, TextStyle style,
      {Size? size, TextPainter? linePaint}) {
    text ??= "";
    linePaint ??= TextPainter(
      textDirection: TextDirection.ltr,
    );
    linePaint.textAlign = lyricPaint.lyricUI.getLyricTextAlign();
    linePaint
      ..text = TextSpan(text: text, style: style)
      ..layout(maxWidth: (size ?? canvasSize).width);
    return linePaint;
  }

  void setTextInlineInfo(LyricDrawInfo drawInfo, LyricUI ui, String text) {
    var linePaint = drawInfo.playingMainTextPainter!;
    var metrics = linePaint.computeLineMetrics();
    var targetLineHeight = 0.0;
    var start = 0;
    List<LyricInlineDrawInfo> lineList = [];
    metrics.forEach((element) {
      //起始偏移量X
      double startOffsetX = 0.0;
      switch (ui.getLyricTextAlign()) {
        case TextAlign.right:
          startOffsetX = linePaint.width - element.width;
          break;
        case TextAlign.center:
          startOffsetX = (linePaint.width - element.width) / 2;
          break;
        default:
          break;
      }
      var offsetX = element.width;
      switch (ui.getLyricTextAlign()) {
        case TextAlign.right:
          offsetX = linePaint.width;
          break;
        case TextAlign.center:
          offsetX = (linePaint.width - element.width) / 2 + element.width;
          break;
        default:
          break;
      }
      var end = linePaint
          .getPositionForOffset(Offset(offsetX, targetLineHeight))
          .offset;
      var lineText = text.substring(start, end);
      LyricsLog.logD("获取行内信息：第${element.lineNumber}行，内容：$lineText");
      lineList.add(LyricInlineDrawInfo()
        ..raw = lineText
        ..number = element.lineNumber
        ..width = element.width
        ..height = element.height
        ..offset = Offset(startOffsetX, targetLineHeight));
      start = end;
      targetLineHeight += element.height;
    });
    drawInfo.inlineDrawList = lineList;
  }

  ///handle widget size
  ///default screenWidth,screenWidth
  ///if outside box has limit,then select min value
  void handleSize() {
    canvasSize = Size(cacheBox?.maxWidth ?? 0, cacheBox?.maxHeight ?? 0);
    refreshLyricHeight(canvasSize);
  }

  void handleTapUp(TapUpDetails event) {
    isDrag = false;

    resumeSelectLineOffset();
  }

  void handleTapDown(TapDownDetails event) {
    disposeSelectLineDelay();
    disposeFiling();

    isDrag = true;
  }

  void handleDragStart(DragStartDetails event) {
    if (widget.blur) {
      lyricPaint.blur = false;
    }

    disposeFiling();
    disposeSelectLineDelay();
    setSelectLine(true);

    if (widget.onScroll != null) {
      widget.onScroll!();
    }
  }

  void handleDragUpdate(DragUpdateDetails event) {
    lyricPaint.lyricOffset += event.primaryDelta ?? 0;
  }

  void handleDragEnd(DragEndDetails event) {
    isDrag = false;

    _flingController = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        if (_flingController == null) return;
        var flingOffset = _flingController!.value;
        lyricPaint.lyricOffset = flingOffset.clamp(lyricPaint.maxOffset, 0);
        if (!lyricPaint.checkOffset(flingOffset)) {
          disposeFiling();
          resumeSelectLineOffset();
          return;
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          disposeFiling();
          resumeSelectLineOffset();
        }
      })
      ..animateWith(ClampingScrollSimulation(
        position: lyricPaint.lyricOffset,
        velocity: event.primaryVelocity ?? 0,
      ));
  }

  ///support touch event
  Widget buildTouchReader(child) => GestureDetector(
        onVerticalDragEnd: handleDragEnd,
        onTap: widget.onTap,
        onTapUp: handleTapUp,
        onTapDown: handleTapDown,
        onVerticalDragStart: handleDragStart,
        onVerticalDragUpdate: handleDragUpdate,
        child: child,
      );

  ///build reader widget
  Container buildReaderWidget() => Container(
        color: Colors.transparent,
        padding: widget.padding ?? EdgeInsets.zero,
        width: widget.size?.width,
        height: widget.size?.height,
        child: LayoutBuilder(
          builder: (c, box) {
            if (cacheBox?.toString() != box.toString()) {
              cacheBox = box;
              handleSize();
            }

            if (widget.model.isNullOrEmpty) {
              return widget.emptyBuilder?.call() ?? Container();
            }

            return CustomPaint(
              isComplex: true,
              willChange: widget.playing == true,
              painter: lyricPaint,
              size: canvasSize,
            );
          },
        ),
      );

  Positioned buildSelectLineWidget() => Positioned(
        top: (widget.padding?.top ?? 0),
        left: 0,
        right: 0,
        child: Container(
          height: lyricPaint.centerY * 2,
          child: Center(
            child: StreamBuilder<int>(
                stream: centerLyricIndexStream.stream,
                builder: (context, snapshot) {
                  final int centerIndex = snapshot.data ?? 0;

                  if (lyricPaint.model.isNullOrEmpty) {
                    return Container();
                  }

                  return widget.selectLineBuilder!.call(
                      lyricPaint.model?.lyrics[centerIndex].startTime ?? 0, () {
                    setSelectLine(false);
                    disposeFiling();
                    disposeSelectLineDelay();
                  });
                }),
          ),
        ),
      );

  ///handle select line
  void resumeSelectLineOffset() {
    isWait = true;

    int waitSecond = 0;

    waitTimer?.cancel();

    waitTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      waitSecond += 100;

      if (waitSecond == 1500) {
        if (widget.blur) {
          lyricPaint.blur = true;
        }

        disposeSelectLineDelay();
        setSelectLine(false);
        scrollToPlayLine();
      }
    });
  }

  void disposeSelectLineDelay() {
    isWait = false;
    waitTimer?.cancel();
  }

  void disposeFiling() {
    _flingController?.dispose();
    _flingController = null;
  }

  void disposeLine() {
    _lineController?.dispose();
    _lineController = null;
  }

  void disposeHighlight() {
    _highlightController?.dispose();
    _highlightController = null;
  }

  ///计算span宽度
  void setTextSpanDrawInfo(
      LyricUI ui, List<LyricSpanInfo> spanList, TextPainter painter) {
    painter.textAlign = lyricPaint.lyricUI.getLyricTextAlign();

    for (final LyricSpanInfo element in spanList) {
      painter
        ..text =
            TextSpan(text: element.raw, style: ui.getPlayingMainTextStyle())
        ..layout();

      element.drawHeight = painter.height;
      element.drawWidth = painter.width;
    }
  }

  /// enable highlight animation
  /// if playing status is null,no highlight.
  void handleHighlight() {
    List<LyricsLineModel>? lyrics = widget.model?.lyrics;

    if (!widget.lyricUI.enableHighlight() ||
        widget.playing == null ||
        widget.model.isNullOrEmpty ||
        lyricPaint.playingIndex >= (lyrics?.length ?? 0) ||
        lyrics == null) {
      return;
    }

    final LyricsLineModel line = lyrics[lyricPaint.playingIndex];
    final List<TweenSequenceItem> items = [];
    double width = 0.0;
    double? firstBegin;
    final spans = line.spanList ?? line.defaultSpanList;
    final blankTime = (line.startTime ?? 0) - widget.position;

    if (blankTime > 0) {
      items.add(TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 0.0), weight: blankTime.toDouble()));
    }

    for (LyricSpanInfo element in spans) {
      if (widget.position >= element.end) {
        width += element.drawWidth;

        continue;
      }

      double ratio = ((widget.position - element.start) / element.duration)
          .clamp(0.0, 1.0);

      double begin = width += (ratio * element.drawWidth);

      firstBegin ??= begin;

      items.add(TweenSequenceItem(
          tween: Tween(begin: begin, end: width += element.drawWidth),
          weight: element.duration.toDouble()));
    }

    disposeHighlight();

    if (items.isEmpty) {
      lyricPaint.highlightWidth = width;
      return;
    }

    final highlightDuration = (line.endTime ?? 0) - widget.position;

    _highlightController ??= AnimationController(
      duration:
          Duration(milliseconds: highlightDuration > 0 ? highlightDuration : 0),
      vsync: this,
    );

    final Animation animate = TweenSequence(items)
        .chain(CurveTween(curve: Curves.linear))
        .animate(_highlightController!)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          disposeHighlight();
        }
      });

    animate.addListener(() {
      lyricPaint.highlightWidth = animate.value;
    });

    if (!(_highlightController?.isAnimating ?? false) &&
        widget.playing == true) {
      _highlightController!.forward();
    } else {
      lyricPaint.highlightWidth = firstBegin ?? width;
    }
  }

  void handleLineTap(int index) {
    if (widget.onLineTap != null && !isDrag && !isWait) {
      widget.onLineTap!(index);
    }
  }

  @override
  void initState() {
    super.initState();

    lyricPaint = LyricsReaderPaint(widget.model, widget.lyricUI, widget.blur)
      ..centerLyricIndexChangeCall = (index) {
        centerLyricIndexStream.add(index);
      };

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      selectLineAndScrollToPlayLine(widget.lyricUI.initAnimation());
    });
  }

  @override
  void dispose() {
    disposeSelectLineDelay();
    disposeFiling();
    disposeLine();
    disposeHighlight();
    centerLyricIndexStream.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LyricsReader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.size?.toString() != widget.size?.toString() ||
        oldWidget.model != widget.model ||
        oldWidget.lyricUI.getKey() != widget.lyricUI.getKey() ||
        oldWidget.lyricUI.getLyricHighlightColor() !=
            widget.lyricUI.getLyricHighlightColor() ||
        oldWidget.blur != widget.blur) {
      lyricPaint.model = widget.model;
      lyricPaint.lyricUI = widget.lyricUI;
      lyricPaint.blur = widget.blur;

      handleSize();
      selectLine(widget.model?.getCurrentLine(widget.position) ?? 0);
      scrollToPlayLine();
      handleHighlight();
    }

    if (oldWidget.position != widget.position) {
      if (_highlightController?.isAnimating != true) {
        handleHighlight();
      }

      selectLineAndScrollToPlayLine();
    }

    if (oldWidget.playing != widget.playing) {
      if (widget.playing == null) {
        lyricPaint.highlightWidth = 0;
      } else {
        if (widget.playing == true) {
          _highlightController?.forward();
        } else {
          _highlightController?.stop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildTouchReader(Stack(
      children: [
        buildReaderWidget(),
        if (widget.selectLineBuilder != null &&
            isShowSelectLineWidget &&
            lyricPaint.centerY != 0)
          buildSelectLineWidget()
      ],
    ));
  }
}
