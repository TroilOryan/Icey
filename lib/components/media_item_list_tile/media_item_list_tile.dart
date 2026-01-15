import "package:audio_service/audio_service.dart";
import "package:IceyPlayer/theme/theme.dart";

import "package:flutter/material.dart";

class MediaItemListTile extends StatelessWidget {
  final bool active;
  final MediaItem media;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const MediaItemListTile(
      this.media, {
        super.key,
        this.active = false,
        this.onTap,
        this.onRemove,
      });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExtension = AppThemeExtension.of(context);

    return Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.all(AppTheme.borderRadiusSm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: theme.cardTheme.color),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              media.title,
                              style: theme.listTileTheme.titleTextStyle
                                  ?.copyWith(
                                color: active
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                      Text(
                        "${media.artist ?? "未知歌手"}-${media.album ?? "未知专辑"}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
                        style: theme.listTileTheme.subtitleTextStyle
                            ?.copyWith(),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Row(
                  children: [
                    InkWell(
                      onTap: onRemove,
                      child: Icon(
                        Icons.remove,
                        color: active ? themeExtension.secondary : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
