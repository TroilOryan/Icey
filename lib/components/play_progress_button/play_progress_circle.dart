import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class PlayProgressCircle extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final double percent;
  final Color? color;

  const PlayProgressCircle(
      {super.key,
      this.size = 40.0,
      this.strokeWidth = 4.0,
      this.percent = 0.8,
      this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        ignoring: true,
        child: CustomPaint(
            isComplex: true,
            willChange: true,
            size: Size(size, size),
            painter: PlayProgressCirclePainter(
                color: color, strokeWidth: strokeWidth, percent: percent)));
  }
}

class PlayProgressCirclePainter extends CustomPainter {
  final double strokeWidth;
  final double percent;
  final Color? color;

  PlayProgressCirclePainter(
      {this.strokeWidth = 10.0, this.percent = 0.8, this.color});

  double get startAngle => -pi / 2;

  double get sweepAngle => 2 * pi * percent;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.width - strokeWidth) / 2;

    final Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = (color ?? AppTheme.primaryColor).withOpacity(0.1);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -2 * pi,
        2 * pi, false, paint);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        sweepAngle, false, paint..color = color ?? AppTheme.primaryColor);
  }

  @override
  bool shouldRepaint(PlayProgressCirclePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.percent != percent;
}
