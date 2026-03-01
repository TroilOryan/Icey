import 'dart:typed_data';

import 'package:IceyPlayer/helpers/media/media.dart';
import 'package:audio_query/audio_query.dart';
import 'package:audio_query/types/artwork_type.dart';
import 'package:audio_service/audio_service.dart';
import 'package:IceyPlayer/components/bottom_sheet/bottom_sheet.dart';
import 'package:IceyPlayer/components/button/button.dart';
import 'package:IceyPlayer/components/icey_switch/icey_switch.dart';
import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/components/media_list_tile/media_list_tile.dart';
import 'package:IceyPlayer/components/media_more_sheet/media_more_sheet.dart';
import 'package:IceyPlayer/components/round_icon_button/round_icon_button.dart';
import 'package:IceyPlayer/components/sheet_item/sheet_item.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/entities/media.dart';
import 'package:IceyPlayer/entities/media_order.dart';
import 'package:IceyPlayer/event_bus/event_bus.dart';
import 'package:IceyPlayer/helpers/image.dart';
import 'package:IceyPlayer/helpers/toast/toast.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/pages/home/controller.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'dart:ui' as ui;

part 'page.dart';

part 'state.dart';

class MediaOrderDetailController {
  final state = MediaOrderDetailState();

  late final String mediaOrderID;

  Widget buildItem(
    BuildContext context,
    int index,
    MediaEntity media,
    MediaItem? mediaItem,
    double paddingBottom,
  ) {
    final isPlaying = mediaItem?.id == media.id;

    return MediaListTile(
      media,
      obscure: false,
      isPlaying: isPlaying,
      onTap: () => homeController.handleMediaTap(media),
      onLongPress: () => handleMediaLongPress(media, context),
    );
  }

  void handleUnlike(String id) {
    MediaHelper.likeMedia(id, false);

    final mediaList = List<MediaEntity>.from(state.mediaList.value);

    mediaList.removeWhere((e) => e.id == id);

    state.mediaList.value = mediaList;

    final index = mediaManager.queue.value.indexWhere(
      (e) => e.id == id,
    );

    if (index != -1) {
      mediaManager.removeQueue(index);
    }
  }

  void handleMediaLongPress(MediaEntity media, BuildContext context) {
    bottomSheet(
      initHeight: 0.4,
      minHeight: 0.4,
      context: context,
      builder: (context, _) => Column(
        spacing: 16,
        children: [
          MediaListTile(media, obscure: false),
          MediaMoreSheet.addToNextPlay(media),
          SheetItem(label: "我不喜欢了", onTap: () => handleUnlike(media.id)),
          MediaMoreSheet.mediaInfo(context, media),
        ],
      ),
    );
  }

  void handlePlayAll() {
    if (state.mediaList.isEmpty) return;

    mediaManager.updateQueue(
      state.mediaList.value.map(MediaEntity.toMediaItem).toList(),
    );

    mediaManager.skipToQueueItem(0);
  }

  void handleChangeCover(BuildContext context) {
    final mediaIDs = _mediaOrderBox.get(mediaOrderID).mediaIDs;

    if (mediaOrderID == '0' || mediaIDs.isEmpty) {
      return;
    }

    final extra = GoRouterState.of(context).extra as Map<String, dynamic>;

    final cover = extra["cover"] as Uint8List;

    final theme = Theme.of(context);
    final customizeCover = signal(
      (state.tempCover.value == null || state.tempCover.value!.isEmpty) &&
          cover.isNotEmpty,
    );
    final Signal<Uint8List?> customizeCoverData = signal(
      cover.isNotEmpty ? cover : null,
    );

    scrollableBottomSheet(
      context: context,
      builder: (context) {
        final _customizeCover = customizeCover.watch(context),
            _customizeCoverData = customizeCoverData.watch(context);

        return [
          Text("修改歌单封面", style: theme.textTheme.titleMedium),
          ListCard(
            children: [
              ListItem(
                title: "自定义封面",
                trailing: IceySwitch(
                  value: _customizeCover,
                  onChanged: (v) => customizeCover.value = v,
                ),
              ),
              Offstage(
                offstage: !_customizeCover,
                child: Center(
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.all(AppTheme.borderRadiusSm),
                    child: Ink(
                      child: InkWell(
                        onLongPress: () => customizeCoverData.value = null,
                        onTap: () async {
                          final res = await ImageHelper().selectImage();

                          if (res != null) {
                            customizeCoverData.value = res;
                          }
                        },
                        child: SizedBox(
                          width: 88,
                          height: 88,
                          child: _customizeCoverData != null
                              ? ExtendedImage.memory(
                                  _customizeCoverData,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Column(
                                    spacing: 8,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(SFIcons.sf_plus),
                                      Text("歌单封面"),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Button(
                block: true,
                child: Text("确认修改"),
                onPressed: () async {
                  if (_customizeCover && _customizeCoverData == null) {
                    showToast("请选择一张图片作为自定义封面");
                  } else if (!_customizeCover) {
                    if (mediaIDs.isNotEmpty) {
                      final coverRes = await AudioQuery().queryArtwork(
                        mediaIDs.last,
                        ArtworkType.AUDIO,
                        size: 512,
                      );

                      state.tempCover.value = coverRes ?? Uint8List(0);

                      eventBus.fire(
                        MediaOrderCoverChange(
                          id: mediaOrderID,
                          cover: null,
                          randomCover: coverRes,
                        ),
                      );

                      final MediaOrderEntity mediaOrder = _mediaOrderBox.get(
                        mediaOrderID,
                      );

                      _mediaOrderBox.put(
                        mediaOrderID,
                        mediaOrder.copyWith(cover: null),
                      );
                    }
                  } else {
                    state.tempCover.value = _customizeCoverData;

                    eventBus.fire(
                      MediaOrderCoverChange(
                        id: mediaOrderID,
                        cover: _customizeCoverData,
                      ),
                    );

                    final MediaOrderEntity mediaOrder = _mediaOrderBox.get(
                      mediaOrderID,
                    );

                    _mediaOrderBox.put(
                      mediaOrderID,
                      mediaOrder.copyWith(cover: _customizeCoverData),
                    );
                  }

                  context.pop();
                },
              ),
            ],
          ),
        ];
      },
    );
  }
}
