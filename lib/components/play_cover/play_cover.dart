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

  PlayNoCoverPainter({required this.primary, required this.secondary});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;

    final Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = primary;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);

    paint.color = secondary;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius / 2,
      paint,
    );

    paint.color = Colors.white24;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 6, paint);
  }

  @override
  bool shouldRepaint(PlayNoCoverPainter oldDelegate) =>
      oldDelegate.primary != primary || oldDelegate.secondary != secondary;
}

class PlayCover extends StatelessWidget {
  final double width;
  final double height;
  final bool noCover;
  final bool? noAnimation;
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
    final theme = Theme.of(context);

    final themeExtension = AppThemeExtension.of(context);

    return FrameSeparateWidget(
      child: Builder(
        builder: (context) {
          final currentMediaItem = mediaManager.currentMediaItem.watch(context),
              currentCover = mediaManager.currentCover.watch(context);

          Widget cover = Container(
            width: width,
            height: height,
            key: ValueKey(currentMediaItem?.id),
            clipBehavior: Clip.antiAlias,
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

          return RepaintBoundary(
            child: AnimatedSwitcher(
              duration: duration ?? AppTheme.defaultDurationLong,
              transitionBuilder: transitionBuilder,
              child: cover,
            ),
          );
        },
      ),
    );
  }
}
