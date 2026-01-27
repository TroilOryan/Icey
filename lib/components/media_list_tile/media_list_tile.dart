import "dart:ui";

import "package:IceyPlayer/components/high_material_wrapper/high_material_wrapper.dart";
import "package:IceyPlayer/components/play_like_button/play_like_button.dart";
import "package:IceyPlayer/helpers/common.dart";
import "package:IceyPlayer/models/media/media.dart";
import "package:flutter_sficon/flutter_sficon.dart";
import "package:IceyPlayer/components/media_cover/media_cover.dart";
import "package:IceyPlayer/components/media_quality/media_quality.dart";
import "package:IceyPlayer/entities/media.dart";

import "package:IceyPlayer/theme/theme.dart";
import "package:flutter/material.dart";

class MediaListTile extends StatelessWidget {
  final MediaEntity media;
  final bool obscure;
  final bool forceObscure;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showAddIcon;
  final bool showDuration;
  final bool showCover;
  final bool showDefault;
  final EdgeInsetsGeometry? margin;
  final bool ghost;
  final bool isPlaying;
  final bool showLike;
  final Function(String? id, bool liked)? onLike;

  const MediaListTile(
    this.media, {
    super.key,
    this.obscure = true,
    this.forceObscure = false,
    this.onTap,
    this.onLongPress,
    this.showAddIcon = true,
    this.showDuration = false,
    this.showCover = true,
    this.showDefault = false,
    this.margin,
    this.ghost = false,
    this.isPlaying = false,
    this.showLike = false,
    this.onLike,
  });

  void handleAddToQueue() {
    final currentIndex = mediaManager.queue.value.indexWhere(
      (item) =>
          item.id == mediaManager.mediaItem.value?.id &&
          item.extras?['uuid'] == mediaManager.mediaItem.value?.extras?['uuid'],
    );

    if (currentIndex != -1) {
      mediaManager.addToQueue(currentIndex + 1, media);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HighMaterialWrapper(
      disabled: !obscure,
      margin: margin,
      borderRadius: BorderRadius.all(AppTheme.borderRadiusSm),
      decoration: (highMaterial) => BoxDecoration(
        color: ghost == true
            ? theme.colorScheme.secondaryContainer
            : theme.cardTheme.color?.withAlpha(
                (forceObscure || (highMaterial && obscure))
                    ? AppTheme.defaultAlphaLight
                    : 255,
              ),
        borderRadius: BorderRadius.all(AppTheme.borderRadiusSm),
      ),
      builder: (highMaterial) => Material(
        borderRadius: BorderRadius.all(AppTheme.borderRadiusSm),
        clipBehavior: Clip.antiAlias,
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: EdgeInsets.fromLTRB(12, 12, showLike ? 10 : 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Offstage(
                  offstage: !showCover,
                  child: MediaCover(
                    showDefault: showDefault,
                    id: media.id,
                    size: 56,
                    borderRadius: BorderRadius.all(AppTheme.borderRadiusXs),
                  ),
                ),
                SizedBox(width: 12),
                Flexible(
                  child: Column(
                    spacing: 3,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              media.title,
                              style: theme.listTileTheme.titleTextStyle
                                  ?.copyWith(
                                    color: isPlaying
                                        ? theme.colorScheme.primary
                                        : null,
                                    height: 1,
                                  ),
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                MediaQuality(quality: media.quality),
                                Flexible(
                                  child: Text(
                                    "${media.artist ?? "未知歌手"}-${media.album ?? "未知专辑"}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style:
                                        theme.listTileTheme.subtitleTextStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Offstage(
                            offstage: !showDuration,
                            child: Container(
                              margin: EdgeInsets.only(left: 6),
                              child: Row(
                                children: [
                                  CommonHelper.buildDuration(
                                    Duration(milliseconds: media.duration!),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Offstage(
                  offstage: onLongPress == null,
                  child: Row(
                    children: [
                      showAddIcon
                          ? InkWell(
                              onTap: handleAddToQueue,
                              child: SFIcon(
                                SFIcons.sf_plus_circle_fill,
                                color: theme.textTheme.bodySmall?.color,
                                fontSize: 16,
                              ),
                            )
                          : const SizedBox(),
                      SizedBox(width: 6),
                      InkWell(
                        onTap: onLongPress,
                        child: Icon(
                          Icons.more_vert,
                          color: theme.textTheme.bodySmall?.color,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Offstage(
                  offstage: !showLike,
                  child: PlayLikeButton(
                    key: ValueKey(media.id),
                    id: media.id.toString(),
                    color: theme.textTheme.bodySmall?.color,
                    size: 23,
                    onTap: (liked) => onLike?.call(media.id.toString(), liked),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
