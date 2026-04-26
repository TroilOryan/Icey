import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:IceyPlayer/components/media_item_list_tile/media_item_list_tile.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import '../../theme/theme.dart';
import '../play_cover/play_cover.dart';

class PlayList extends StatefulWidget {
  const PlayList({super.key});

  @override
  State<PlayList> createState() => _PlayListState();
}

class _PlayListState extends State<PlayList> {
  final listController = ListController();
  final scrollController = ScrollController();

  late final StreamSubscription<MediaItem?> _mediaItemSub;
  late final StreamSubscription<List<MediaItem>> _queueSub;

  @override
  void initState() {
    super.initState();

    // 初始加载时立即滚动到当前歌曲
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrent();
    });

    // 当前歌曲变化时滚动
    _mediaItemSub = mediaManager.mediaItem.listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrent();
      });
    });

    // 队列变化时（如 shuffle 重排）也滚动到当前歌曲
    _queueSub = mediaManager.queue.listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrent();
      });
    });
  }

  void _scrollToCurrent() {
    if (!listController.isAttached) return;

    final currentMedia = mediaManager.mediaItem.value;
    if (currentMedia == null) return;

    final queue = mediaManager.queue.value;
    final index = queue.indexWhere(
      (item) =>
          item.id == currentMedia.id &&
          item.extras?['uuid'] == currentMedia.extras?['uuid'],
    );

    if (index >= 0 && index < queue.length) {
      listController.jumpToItem(
        index: index,
        scrollController: scrollController,
        alignment: 0,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();

    _mediaItemSub.cancel();
    _queueSub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final themeExtension = AppThemeExtension.of(context);

    return StreamBuilder(
      stream: mediaManager.queue,
      builder: (context, snapshot) {
        final queue = snapshot.data;

        return Column(
          spacing: 16,
          children: [
            Container(
              padding: const .symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
              ),
              child: Row(
                children: [
                  PlayCover(
                    width: 55,
                    height: 55,
                    borderRadius: .circular(27.5),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: .start,
                      mainAxisAlignment: .center,
                      children: [
                        StreamBuilder(
                          stream: mediaManager.mediaItem,
                          builder: (context, snapshot) {
                            final mediaItem = snapshot.data;

                            return Column(
                              crossAxisAlignment: .start,
                              children: [
                                Text(
                                  mediaItem?.title ?? "暂无歌曲",
                                  style: theme.textTheme.titleSmall,
                                  maxLines: 2,
                                  softWrap: true,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  mediaItem?.artist ?? "暂无歌手",
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: SuperListView.builder(
                  listController: listController,
                  controller: scrollController,
                  itemCount: queue?.length ?? 0,
                  itemBuilder: (context, index) => Container(
                    margin: .only(
                      bottom: queue != null
                          ? index == queue.length - 1
                                ? 16
                                : 8
                          : 8,
                    ),
                    child: MediaItemListTile(
                      queue![index],
                      active:
                          mediaManager.mediaItem.value?.id == queue[index].id &&
                          mediaManager.mediaItem.value?.extras?['uuid'] ==
                              queue[index].extras?['uuid'],
                      onTap: () => mediaManager.skipToQueueItem(index),
                      onRemove: () => mediaManager.removeQueue(index),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
