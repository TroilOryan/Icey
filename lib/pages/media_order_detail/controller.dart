part of 'page.dart';

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
    final isPlaying = mediaItem?.id == media.id.toString();

    return MediaListTile(
      media,
      obscure: false,
      isPlaying: isPlaying,
      onTap: () => homeController.handleMediaTap(media),
      onLongPress: () => handleMediaLongPress(media, context),
    );
  }

  void handleUnlike(int id) {
    MediaHelper.likeMedia(id.toString(), false);

    final mediaList = List<MediaEntity>.from(state.mediaList.value);

    mediaList.removeWhere((e) => e.id == id);

    state.mediaList.value = mediaList;

    final index = mediaManager.queue.value.indexWhere(
      (e) => e.id == id.toString(),
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
