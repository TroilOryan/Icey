import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class MediaDefaultCover extends StatelessWidget {
  final Size? size;
  final bool? isDarkMode;
  final BorderRadiusGeometry? borderRadius;

  const MediaDefaultCover({
    super.key,
    required this.size,
    required this.isDarkMode,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: borderRadius),
      child: ExtendedImage.asset(
        isDarkMode == true
            ? 'assets/images/no_cover_dark.png'
            : 'assets/images/no_cover.png',
        gaplessPlayback: true,
        width: size?.width,
        height: size?.height,
        fit: BoxFit.cover,
      ),
    );
  }
}
