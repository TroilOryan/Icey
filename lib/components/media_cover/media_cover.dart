import 'dart:typed_data';

import 'package:IceyPlayer/components/scroll_aware_future_builder/scroll_aware_future_builder.dart';
import 'package:IceyPlayer/helpers/platform.dart';
import 'package:IceyPlayer/src/rust/api/tag_reader.dart';
import 'package:audio_query/query_artwork_widget/query_artwork_widget.dart';
import 'package:audio_query/types/artwork_type.dart';
import 'package:flutter/material.dart';

import '../media_default_cover/media_default_cover.dart';

class MediaCover extends StatelessWidget {
  final String? id;
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
      if (PlatformHelper.isDesktop) {
        return ScrollAwareFutureBuilder(
          future: () => getPictureFromPath(
            path: id!,
            width: (width ?? size).toInt(),
            height: (height ?? size).toInt(),
          ),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Container(
                width: width ?? size,
                height: height ?? size,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(borderRadius: borderRadius),
                child: MediaDefaultCover(
                  size: Size(width ?? size, height ?? size),
                  isDarkMode: isDarkMode,
                  borderRadius: borderRadius,
                ),
              );
            }

            return Container(
              clipBehavior: Clip.antiAlias,
              width: width ?? size,
              height: height ?? size,
              decoration: BoxDecoration(borderRadius: borderRadius),
              child: Image.memory(snapshot.data!, gaplessPlayback: true),
            );
          },
        );
      }

      return QueryArtworkWidget(
        keepOldArtwork: keepOldArtwork,
        id: id!,
        type: type,
        size: (size * 2.5).round(),
        artworkWidth: width ?? size,
        artworkHeight: height ?? size,
        quality: 50,
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
