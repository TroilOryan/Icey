import 'package:IceyPlayer/components/play_progress_bar/play_progress_bar_painter.dart';
import 'package:IceyPlayer/helpers/common.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../theme/theme.dart';

final _progressBarHeight = 8.0;

class PlayProgressBarState {
  final Signal<Duration> duration = signal(Duration.zero);

  final Signal<Duration> position = signal(Duration.zero);

  final Signal<double> dragPosition = signal(0.0);

  final Signal<bool> isDragging = signal(false);

  final Signal<bool> draggable = signal(false);

  final Signal<Duration> dragDuration = signal(Duration.zero);
}

class PlayProgressBar extends StatefulWidget {
  final String? quality;
  final ValueChanged<Duration> onChangeEnd;

  const PlayProgressBar({
    super.key,
    required this.quality,
    required this.onChangeEnd,
  });

  @override
  State<PlayProgressBar> createState() => _PlayProgressBarState();
}

class _PlayProgressBarState extends State<PlayProgressBar> {
  int _lastDragUpdateTime = 0;

  final state = PlayProgressBarState();

  late final EffectCleanup positionListener;

  void handleHorizontalDragDown(DragDownDetails details) {
    if (!state.draggable.value) return;

    state.isDragging.value = true;
  }

  void handleHorizontalDragUpdate(
    DragUpdateDetails details,
    BuildContext context,
  ) {
    if (!state.isDragging.value || !state.draggable.value) return;

    // 计算当前时间
    final now = DateTime.now().microsecondsSinceEpoch;
    // 限制更新频率为60fps (约16ms一次)
    if (now - _lastDragUpdateTime < 16000) {
      return;
    }

    _lastDragUpdateTime = now;

    final newPosition = (details.localPosition.dx / context.size!.width).clamp(
      0.0,
      1.0,
    );

    batch(() {
      state.dragPosition.value = newPosition;
      state.dragDuration.value = Duration(
        milliseconds:
            (state.dragPosition.value * state.duration.value.inMilliseconds)
                .toInt(),
      );
    });
  }

  void handleHorizontalDragEnd(DragEndDetails details) {
    state.isDragging.value = false;

    widget.onChangeEnd(
      Duration(milliseconds: state.dragDuration.value.inMilliseconds),
    );
  }

  void handleTapUp(TapUpDetails details) {
    state.isDragging.value = false;
  }

  void handleTapDown(TapDownDetails details, BuildContext context) {
    if (!state.draggable.value) return;

    final newPosition = (details.localPosition.dx / context.size!.width).clamp(
      0.0,
      1.0,
    );

    batch(() {
      state.dragPosition.value = newPosition;
      state.dragDuration.value = Duration(
        milliseconds:
            (state.dragPosition.value * state.duration.value.inMilliseconds)
                .toInt(),
      );
    });

    widget.onChangeEnd(
      Duration(
        milliseconds: (newPosition * state.duration.value.inMilliseconds)
            .toInt(),
      ),
    );
  }

  void updatePosition(Duration position, Duration duration) {
    if (state.isDragging.value) return;

    final nowMs = position.inMilliseconds, totalMs = duration.inMilliseconds;

    final double dragPosition = (nowMs / totalMs).isNaN
        ? 0.0
        : (nowMs / totalMs);

    batch(() {
      state.dragPosition.value = dragPosition.clamp(0.0, 1.0);

      if (totalMs == 0) {
        state.draggable.value = false;
      } else {
        state.draggable.value = true;
      }
    });
  }

  void onInit() {
    mediaManager.mediaItem.listen((mediaItem) {
      state.duration.value = (mediaItem == null || mediaItem.duration == null)
          ? Duration.zero
          : mediaItem.duration!;

      updatePosition(mediaManager.position.value, state.duration.value);
    });

    positionListener = effect(() {
      updatePosition(mediaManager.position.value, state.duration.value);

      state.position.value = mediaManager.position.value;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    positionListener();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    onInit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final themeExtension = AppThemeExtension.of(context);

    final progressBarColor = themeExtension.primary;

    final progressBarBgColor = themeExtension.secondaryContainer;

    final duration = state.duration.watch(context),
        position = state.position.watch(context),
        dragPosition = state.dragPosition.watch(context),
        isDragging = state.isDragging.watch(context),
        dragDuration = state.dragDuration.watch(context);

    return GestureDetector(
      onHorizontalDragDown: handleHorizontalDragDown,
      onHorizontalDragUpdate: (details) =>
          handleHorizontalDragUpdate(details, context),
      onHorizontalDragEnd: handleHorizontalDragEnd,
      onTapUp: handleTapUp,
      onTapDown: (details) => handleTapDown(details, context),
      child: LayoutBuilder(
        builder: (context, constrains) => Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedScale(
              alignment: Alignment.center,
              scale: isDragging ? 1.02 : 1,
              duration: AppTheme.defaultDuration,
              child: CustomPaint(
                isComplex: true,
                willChange: true,
                size: Size.fromHeight(_progressBarHeight),
                painter: PlayProgressBarBgPainter(color: progressBarBgColor),
                foregroundPainter: PlayProgressBarPainter(
                  position: dragPosition,
                  color: progressBarColor,
                ),
              ),
            ),
            Positioned(
              top: _progressBarHeight + 8,
              left: dragPosition * constrains.maxWidth - 32,
              child: Offstage(
                offstage: !isDragging,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                  decoration: BoxDecoration(
                    color: progressBarBgColor,
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusXs,
                    ),
                  ),
                  child: CommonHelper.buildDuration(
                    dragDuration,
                    progressBarColor,
                    theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: isDragging ? 0.5 : 1,
              duration: AppTheme.defaultDuration,
              child: Padding(
                padding: EdgeInsets.only(top: _progressBarHeight + 10),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Offstage(
                      offstage: widget.quality == null,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: progressBarBgColor,
                            ),
                            child: Text(
                              widget.quality ?? "",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontSize: 10,
                                    color: progressBarColor,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonHelper.buildDuration(
                          position,
                          progressBarColor,
                          theme.textTheme.bodyMedium,
                        ),
                        CommonHelper.buildDuration(
                          duration,
                          progressBarColor,
                          theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
