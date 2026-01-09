import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PlayLyricShaderMask extends StatelessWidget {
  final double height;
  final List<double>? colorStops;
  final Widget child;

  const PlayLyricShaderMask(
      {super.key, required this.height, this.colorStops, required this.child});

  @override
  Widget build(BuildContext context) {
    final stops = colorStops ?? const [0.0, 0.15, 0.85, 1];

    return SizedBox(
        height: height,
        child: ShaderMask(
            shaderCallback: (rect) {
              return ui.Gradient.linear(
                  Offset(rect.width / 2, 0),
                  Offset(rect.width / 2, height),
                  [
                    Colors.white.withOpacity(0),
                    Colors.white,
                    Colors.white,
                    Colors.white.withOpacity(0)
                  ],
                  stops);
            },
            child: child));
  }
}
