import 'dart:typed_data';

import 'package:audio_query/query_artwork_widget/query_artwork_widget.dart';
import 'package:audio_query/types/artwork_type.dart';
import 'package:flutter/material.dart';

import '../media_default_cover/media_default_cover.dart';

class MediaCover extends StatelessWidget {
  final int? id;
  final double size;
  final double? width;
  final double? height;
  final int? quality;
  final bool? showDefault;
  final bool keepOldArtwork;
  final bool? isDarkMode;
  final ArtworkType type;
  final BorderRadius? borderRadius;
  final Function(Uint8List)? onQueried;

  const MediaCover({
    super.key,
    required this.id,
    this.size = 50,
    this.width,
    this.height,
    this.quality,
    this.showDefault,
    this.keepOldArtwork = true,
    this.isDarkMode,
    this.type = ArtworkType.AUDIO,
    this.borderRadius,
    this.onQueried,
  });

  @override
  Widget build(BuildContext context) {
    if (showDefault != true && id != null) {
      return QueryArtworkWidget(
        keepOldArtwork: keepOldArtwork,
        id: id!,
        type: type,
        size: (size * 4).round(),
        artworkWidth: width ?? size,
        artworkHeight: height ?? size,
        quality: 100,
        artworkBorder: borderRadius,
        frameBuilder:
            (
              BuildContext context,
              Widget child,
              int? frame,
              bool wasSynchronouslyLoaded,
            ) {
              if (!wasSynchronouslyLoaded) {
                return child;
              }

              return AnimatedOpacity(
                opacity: frame == null ? 0.5 : 1,
                duration: const Duration(milliseconds: 200),
                curve: Curves.linear,
                child: child,
              );
            },
        nullArtworkWidget: Container(
          width: width ?? size,
          height: height ?? size,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: borderRadius),
          child: MediaDefaultCover(
            size: Size(width ?? size, height ?? size),
            isDarkMode: isDarkMode,
            borderRadius: borderRadius,
          ),
        ),
        onQueried: onQueried,
      );
    }

    return MediaDefaultCover(
      key: const ValueKey('defaultCover'),
      size: Size(width ?? size, height ?? size),
      isDarkMode: isDarkMode,
      borderRadius: borderRadius,
    );
  }
}
