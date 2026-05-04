import "dart:ui";

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
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      type: .transparency,
      borderRadius: .circular(AppTheme.borderRadiusSm),
      clipBehavior: .antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withAlpha(13),
                          Colors.white.withAlpha(5),
                        ]
                      : [
                          Colors.white.withAlpha(160),
                          Colors.white.withAlpha(100),
                        ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withAlpha(22)
                      : Colors.white.withAlpha(100),
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: const .symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: .start,
                        mainAxisAlignment: .center,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: .ellipsis,
                                  media.title,
                                  style: theme.listTileTheme.titleTextStyle
                                      ?.copyWith(
                                        color: active
                                            ? theme.colorScheme.primary
                                            : null,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                          Text(
                            "${media.artist ?? "未知歌手"}-${media.album ?? "未知专辑"}",
                            overflow: .ellipsis,
                            maxLines: 1,
                            softWrap: true,
                            style: theme.listTileTheme.subtitleTextStyle
                                ?.copyWith(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
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
        ),
      ),
    );
  }
}
