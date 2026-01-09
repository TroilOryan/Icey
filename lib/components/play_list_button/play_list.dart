import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:IceyPlayer/components/marquee/marquee.dart';
import 'package:IceyPlayer/components/media_item_list_tile/media_item_list_tile.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  late final StreamSubscription<MediaItem?> listener;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final index = mediaManager.queue.value.indexWhere(
          (queue) =>
      queue.id == mediaManager.mediaItem.value?.id &&
          queue.extras?['uuid'] ==
              mediaManager.mediaItem.value?.extras?['uuid'],
    );

    Future.delayed(const Duration(milliseconds: 500)).then((_) {
      if (index != -1 &&
          index >= 0 &&
          index < mediaManager.queue.value.length - 1 &&
          listController.isAttached) {
        listController.jumpToItem(
          index: index,
          scrollController: scrollController,
          alignment: 0,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((callback) {
      listener = mediaManager.mediaItem.listen((mediaItem) {
        final index = mediaManager.queue.value.indexWhere(
              (queue) =>
          queue.id == mediaItem?.id &&
              queue.extras?['uuid'] == mediaItem?.extras?['uuid'],
        );

        if (index != -1 &&
            index >= 0 &&
            index < mediaManager.queue.value.length - 1 &&
            listController.isAttached) {
          listController.jumpToItem(
            index: index,
            scrollController: scrollController,
            alignment: 0,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    listener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final themeExtension = AppThemeExtension.of(context);

    return StreamBuilder(
      stream: mediaManager.queue,
      builder: (context, snapshot) {
        final queue = snapshot.data;

        return Container(
          margin: EdgeInsets.only(top: 16.h),
          child: Column(
            spacing: 16.h,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.all(AppTheme.borderRadiusSm),
                ),
                child: Row(
                  children: [
                    PlayCover(
                      width: 55.h,
                      height: 55.h,
                      borderRadius: BorderRadius.all(AppTheme.borderRadiusSm),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StreamBuilder(
                            stream: mediaManager.mediaItem,
                            builder: (context, snapshot) {
                              final mediaItem = snapshot.data;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mediaItem?.title ?? "暂无歌曲",
                                    style: theme.textTheme.titleSmall,
                                    maxLines: 2,
                                    softWrap: true,
                                  ),
                                  SizedBox(width: 12.w),
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
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    itemCount: queue?.length ?? 0,
                    itemBuilder: (context, index) => Container(
                      margin: EdgeInsets.only(
                        bottom: queue != null
                            ? index == queue.length - 1
                            ? 16.h
                            : 8.h
                            : 8.h,
                      ),
                      child: MediaItemListTile(
                        queue![index],
                        active:
                        mediaManager.mediaItem.value?.id ==
                            queue[index].id &&
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
          ),
        );
      },
    );
  }
}
