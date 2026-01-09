import 'package:IceyPlayer/components/play_progress_bar/play_progress_bar_painter.dart';
import 'package:IceyPlayer/helpers/common.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signals/signals_flutter.dart';

import '../../theme/theme.dart';

final _progressBarHeight = 8.h;

class PlayProgressBarState {
  final Signal<Duration> duration = signal(Duration.zero);

  final Signal<Duration> position = signal(Duration.zero);

  final Signal<double> dragPosition = signal(0.0);
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
  late final EffectCleanup positionListener;

  final state = PlayProgressBarState();

  bool draggable = true;

  bool isDragging = false;

  int _lastDragUpdateTime = 0;

  Duration dragDuration = const Duration(milliseconds: 0);

  void handleHorizontalDragDown(DragDownDetails details) {
    if (!draggable) return;

    isDragging = true;
  }

  void handleHorizontalDragUpdate(
    DragUpdateDetails details,
    BuildContext context,
  ) {
    if (!isDragging || !draggable) return;

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

    state.dragPosition.value = newPosition;
    dragDuration = Duration(
      milliseconds: (state.dragPosition * state.duration.value.inMilliseconds)
          .toInt(),
    );
  }

  void handleHorizontalDragEnd(DragEndDetails details) {
    isDragging = false;

    widget.onChangeEnd(
      Duration(
        milliseconds: (state.dragPosition * state.duration.value.inMilliseconds)
            .toInt(),
      ),
    );
  }

  void handleTapUp(TapUpDetails details) {
    isDragging = false;
  }

  void handleTapDown(TapDownDetails details, BuildContext context) {
    if (!draggable) return;

    final newPosition = (details.localPosition.dx / context.size!.width).clamp(
      0.0,
      1.0,
    );

    state.dragPosition.value = newPosition;
    dragDuration = Duration(
      milliseconds: (state.dragPosition * state.duration.value.inMilliseconds)
          .toInt(),
    );

    widget.onChangeEnd(
      Duration(
        milliseconds: (newPosition * state.duration.value.inMilliseconds)
            .toInt(),
      ),
    );
  }

  void updatePosition(Duration position, Duration duration) {
    if (isDragging) return;

    final nowMs = position.inMilliseconds, totalMs = duration.inMilliseconds;

    final double _position = (nowMs / totalMs).isNaN ? 0.0 : (nowMs / totalMs);

    state.dragPosition.value = _position.clamp(0.0, 1.0);

    if (totalMs == 0) {
      draggable = false;
    } else {
      draggable = true;
    }
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
        dragPosition = state.dragPosition.watch(context);

    return RepaintBoundary(
      child: GestureDetector(
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
                top: _progressBarHeight + 8.h,
                left: dragPosition * constrains.maxWidth - 32.w,
                child: Offstage(
                  offstage: !isDragging,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(8.w, 2.h, 8.w, 2.h),
                    decoration: BoxDecoration(
                      color: progressBarBgColor,
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
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
                  padding: EdgeInsets.only(top: _progressBarHeight + 10.h),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Offstage(
                        offstage: widget.quality == null,
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4.r),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              decoration: BoxDecoration(
                                color: progressBarBgColor,
                              ),
                              child: Text(
                                widget.quality ?? "",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontSize: 10.sp,
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
      ),
    );
  }
}
