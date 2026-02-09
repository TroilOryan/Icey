import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:IceyPlayer/components/media_list_tile/media_list_tile.dart';
import 'package:IceyPlayer/entities/media.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class MediaList extends StatelessWidget {
  final bool showDuration;
  final List<MediaEntity> mediaList;
  final Map<int, BuildContext> sliverContextMap;
  final Function(MediaEntity) onTap;
  final Function(MediaEntity) onLongPress;

  const MediaList({
    super.key,
    required this.showDuration,
    required this.mediaList,
    required this.sliverContextMap,
    required this.onTap,
    required this.onLongPress,
  });

  Widget buildItem({
    required BuildContext context,
    required int index,
    required MediaItem? mediaItem,
    required double paddingBottom,
  }) {
    if (sliverContextMap[index] == null) {
      sliverContextMap[index] = context;
    }

    final item = mediaList[index];

    final isPlaying = mediaItem?.id == item.id.toString();

    return MediaListTile(
      item,
      showDuration: showDuration,
      isPlaying: isPlaying,
      margin: index == mediaList.length - 1
          ? EdgeInsets.only(bottom: paddingBottom + 64)
          : null,
      onTap: () => onTap(item),
      onLongPress: () => onLongPress(item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final double paddingBottom = max(mediaQuery.padding.bottom, 16);

    return StreamBuilder(
      stream: mediaManager.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SuperSliverList.separated(
            addAutomaticKeepAlives: true,
            itemCount: mediaList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => buildItem(
              context: context,
              index: index,
              mediaItem: mediaItem,
              paddingBottom: paddingBottom,
            ),
          ),
        );
      },
    );
  }
}
