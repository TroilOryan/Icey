import 'package:flutter/material.dart';

const _progressBarRadius = Radius.circular(20);

class PlayProgressBarBgPainter extends CustomPainter {
  final Color color;

  const PlayProgressBarBgPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = color;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        _progressBarRadius,
      ),
      backgroundPaint,
    );
  }

  @override
  bool shouldRepaint(PlayProgressBarBgPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

const double _visualThreshold = 0.001;

class PlayProgressBarPainter extends CustomPainter {
  final double position;
  final Color color;

  const PlayProgressBarPainter({required this.position, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final foregroundPaint = Paint()..color = color;

    // 绘制前景
    if (position > 0.995) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width * position, size.height),
          _progressBarRadius,
        ),
        foregroundPaint,
      );
    } else if (position < 0.01) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, 0, size.width * 0.01, size.height),
          topLeft: _progressBarRadius,
          bottomLeft: _progressBarRadius,
        ),
        foregroundPaint,
      );
    } else {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, 0, size.width * position, size.height),
          topLeft: _progressBarRadius,
          bottomLeft: _progressBarRadius,
        ),
        foregroundPaint,
      );
    }
  }

  @override
  bool shouldRepaint(PlayProgressBarPainter oldDelegate) {
    // 检查位置变化是否超过视觉阈值或颜色变化
    return (position - oldDelegate.position).abs() > _visualThreshold ||
        oldDelegate.color != color;
  }
}