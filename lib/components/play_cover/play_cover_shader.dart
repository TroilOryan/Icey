import 'dart:math';
import 'dart:ui' as ui;
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';

/// 播放封面沉浸
class PlayCoverShader extends StatelessWidget {
  final double? offset;
  final double height;
  final List<double>? colorStops;
  final Widget child;
  final bool isLandscape;

  const PlayCoverShader({
    super.key,
    this.offset,
    required this.height,
    this.colorStops,
    required this.child,
    this.isLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final List<double> verticalStops =
        colorStops ??
        (isLandscape ? const [0, 0, 0.3, 1.0] : const [0.0, 0.0, 0.3, 1]);

    final alignmentX = (2 * 32 / height) - 1;

    final alignmentY = (2 * (32 + mediaQuery.padding.top) / height) - 1;

    final scale = max(1 - (offset ?? 0) / mediaQuery.size.width, 0.2);

    final double opacity = min(
      0 + (offset ?? 0) / 2 / mediaQuery.size.width,
      1,
    );

    Widget cover = AnimatedContainer(
      duration: AppTheme.defaultDuration,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: scale < 1
            ? BorderRadius.all(AppTheme.borderRadiusLg)
            : null,
      ),
      child: child,
    );

    Widget shader = ShaderMask(
      key: ValueKey(isLandscape),
      shaderCallback: (rect) {
        return ui.Gradient.linear(
          isLandscape ? Offset(0, rect.width) : Offset(rect.width / 2, 0),
          isLandscape
              ? Offset(rect.width, rect.width)
              : Offset(rect.width / 2, height),
          [
            Colors.white.withAlpha(0),
            Colors.white,
            Colors.white,
            Colors.white.withAlpha(0),
          ],
          verticalStops,
        );
      },
      child: cover,
    );

    return AnimatedScale(
      curve: Curves.easeInOutSine,
      duration: AppTheme.defaultDurationMid,
      alignment: Alignment(alignmentX, -1),
      scale: scale,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            shader,
            // 保证缩小后没有shader
            AnimatedOpacity(
              opacity: opacity,
              duration: AppTheme.defaultDurationMid,
              child: AnimatedContainer(
                duration: AppTheme.defaultDurationMid,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(AppTheme.borderRadiusLg),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
