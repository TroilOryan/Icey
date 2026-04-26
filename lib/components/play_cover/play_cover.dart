import 'package:IceyPlayer/components/media_default_cover/media_default_cover.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:keframe/keframe.dart';
import 'package:signals/signals_flutter.dart';

class PlayNoCoverPainter extends CustomPainter {
  final Color primary;
  final Color secondary;

  const PlayNoCoverPainter({required this.primary, required this.secondary});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = primary;

    canvas.drawCircle(center, radius, paint);

    paint.color = secondary;
    canvas.drawCircle(center, radius / 2, paint);

    paint.color = Colors.white24;
    canvas.drawCircle(center, 6, paint);
  }

  @override
  bool shouldRepaint(PlayNoCoverPainter oldDelegate) =>
      oldDelegate.primary != primary || oldDelegate.secondary != secondary;
}

class PlayCover extends StatelessWidget {
  final double width;
  final double height;
  final bool noCover;
  final bool noAnimation;
  final Duration? duration;
  final Widget Function(Widget, Animation<double>) transitionBuilder;
  final ImageRepeat repeat;
  final FilterQuality filterQuality;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const PlayCover({
    super.key,
    this.width = 50,
    this.height = 50,
    this.noCover = false,
    this.noAnimation = false,
    this.duration,
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.repeat = ImageRepeat.noRepeat,
    this.filterQuality = FilterQuality.high,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final themeExtension = AppThemeExtension.of(context);

    final content = Builder(
      builder: (context) {
        final currentMediaItem = mediaManager.currentMediaItem.watch(context),
            currentCover = mediaManager.currentCover.watch(context);

        Widget cover = Container(
          width: width,
          height: height,
          key: ValueKey(currentMediaItem?.id),
          clipBehavior: .antiAlias,
          decoration: BoxDecoration(borderRadius: borderRadius),
          child: currentCover.isNotEmpty
              ? ExtendedImage.memory(
                  currentCover,
                  width: width,
                  height: height,
                  fit: fit,
                  gaplessPlayback: true,
                  repeat: repeat,
                  filterQuality: filterQuality,
                )
              : noCover == true
              ? CustomPaint(
                  willChange: true,
                  painter: PlayNoCoverPainter(
                    primary: themeExtension.primaryContainer,
                    secondary: themeExtension.secondaryContainer,
                  ),
                )
              : MediaDefaultCover(
                  size: Size(width, height),
                  isDarkMode: false,
                ),
        );

        if (noAnimation == true) {
          return cover;
        }

        return AnimatedSwitcher(
          duration: duration ?? AppTheme.defaultDurationLong,
          transitionBuilder: transitionBuilder,
          child: cover,
        );
      },
    );

    // 背景等不需要动画的场景直接构建，不做帧分离
    if (noAnimation == true) {
      return content;
    }

    return FrameSeparateWidget(child: content);
  }
}
