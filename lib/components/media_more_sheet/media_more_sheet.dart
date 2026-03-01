import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:filesize/filesize.dart';
import 'package:IceyPlayer/components/bottom_sheet/bottom_sheet.dart';
import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/components/media_cover/media_cover.dart';
import 'package:IceyPlayer/components/sheet_item/sheet_item.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/entities/media.dart';
import 'package:IceyPlayer/entities/media_order.dart';
import 'package:IceyPlayer/event_bus/event_bus.dart';
import 'package:IceyPlayer/helpers/common.dart';
import 'package:IceyPlayer/helpers/media/media.dart';
import 'package:IceyPlayer/helpers/toast/toast.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mime_type/mime_type.dart';
import 'package:open_app/open_app.dart';

class MusicInfo {
  final String filePath;
  final String uri;
  final String title;
  final int duration;

  MusicInfo({
    required this.filePath,
    required this.title,
    required this.uri,
    required this.duration,
  });

  // 转换为Map（关键步骤）
  Map<String, dynamic> toMap() {
    return {'filePath': filePath, 'title': title, 'duration': duration};
  }
}

final _likedBox = Boxes.likedBox,
    _mediaOrderBox = Boxes.mediaOrderBox,
    _mediaCountBox = Boxes.mediaCountBox;

class MediaMoreSheet {
  static addToNextPlay(MediaEntity media) {
    final currentIndex = mediaManager.queue.value.indexWhere(
      (item) =>
          item.id == mediaManager.mediaItem.value?.id &&
          item.extras?['uuid'] == mediaManager.mediaItem.value?.extras?['uuid'],
    );

    return SheetItem(
      label: "下一首播放",
      onTap: () => mediaManager.addToQueue(currentIndex + 1, media),
    );
  }

  static likeMedia(BuildContext context, MediaEntity media) {
    final likedIDs = _likedBox.keys.toList();

    return SheetItem(
      label: likedIDs.contains(media.id) ? "我不喜欢了" : "我喜欢",
      onTap: () {
        final liked = likedIDs.contains(media.id);

        if (liked) {
          _likedBox.delete(media.id);
        } else {
          _likedBox.put(media.id, true);
        }

        eventBus.fire(LikeMediaChange(media.id, !liked));

        context.pop();
      },
    );
  }

  static addToMediaOrder(BuildContext context, MediaEntity media) {
    return SheetItem(
      label: "添加到歌单",
      onTap: () {
        Future.delayed(
          const Duration(milliseconds: 50),
        ).then((_) => showMediaOrder(context, media));
      },
    );
  }

  static showMediaOrder(BuildContext context, MediaEntity media) {
    final theme = Theme.of(context);

    final List<MediaOrderEntity> mediaOrder = _mediaOrderBox.values
        .toList()
        .reversed
        .toList()
        .cast<MediaOrderEntity>();

    scrollableBottomSheet(
      context: context,
      builder: (context) => [
        Text("添加到歌单", style: theme.textTheme.titleMedium),
        ListCard(
          spacing: 16,
          children: mediaOrder
              .map(
                (e) => ListItem(
                  icon: Container(
                    width: 50,
                    height: 50,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: e.cover != null
                        ? ExtendedImage.memory(
                            e.cover!,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          )
                        : e.mediaIDs.isNotEmpty
                        ? MediaCover(
                            id: e.mediaIDs.last,
                            size: 50,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )
                        : ExtendedImage.asset(
                            'assets/images/no_cover.png',
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          ),
                  ),
                  title: e.name,
                  desc: e.mediaIDs.length.toString(),
                  onTap: () {
                    final MediaOrderEntity order = _mediaOrderBox.get(e.id);

                    if (order.mediaIDs.contains(media.id)) {
                      showToast("已添加到该歌单");

                      return;
                    }

                    order.mediaIDs.add(media.id);

                    _mediaOrderBox.put(e.id, order);

                    eventBus.fire(
                      MediaOrderChange(
                        id: e.id,
                        name: e.name,
                        mediaIDs: order.mediaIDs,
                      ),
                    );

                    context.pop();

                    showToast("已添加到歌单");
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  static deleteMedia(MediaEntity media) {
    return SheetItem(label: "删除", onTap: () => MediaHelper.deleteMedia(media));
  }

  static mediaInfo(BuildContext context, MediaEntity media) {
    return SheetItem(
      label: "媒体信息",
      onTap: () {
        Future.delayed(
          const Duration(milliseconds: 50),
        ).then((_) => showMediaInfo(context, media));
      },
    );
  }

  static mediaArtist(BuildContext context, MediaEntity mediaItem) {
    final index = mediaManager.artistList.value.indexWhere(
      (e) => e.id == mediaItem.artistID,
    );

    return SheetItem(
      label: '艺术家: ${mediaItem.artist}',
      onTap: () => context.push(
        "/artist_list_detail/${mediaItem.artistID}",
        extra: {
          "name": mediaItem.artist,
          "mediaIDs": mediaManager.artistList.value[index].mediaIDs,
        },
      ),
    );
  }

  static mediaAlbum(BuildContext context, MediaEntity media) {
    final index = mediaManager.albumList.value.indexWhere(
      (e) => e.id == media.albumID,
    );

    return SheetItem(
      label: '专辑: ${media.album}',
      onTap: () => context.push(
        "/album_list_detail/${media.albumID}",
        extra: {
          "name": media.album,
          "mediaIDs": mediaManager.albumList.value[index].mediaIDs,
        },
      ),
    );
  }

  // 打开音乐标签
  static openInMusicTagEditor(MediaEntity media) {
    var _app = OpenApp();

    return SheetItem(
      label: '在音乐标签中打开',
      onTap: () async => await _app.openActivity(
        appId: "com.xjcheng.musictageditor",
        // activity: "SongDetailActivity",
        activity: "MainActivity",
        // extras: {
        //   "song_filePath": media.data,
        //   "song_id": media.id,
        //   "song_filepath": media.data,
        //   'song': jsonEncode({
        //     "song_id": media.id,
        //     "song_filepath": media.data,
        //   }),
        // },
      ),
    );
  }

  static showMediaInfo(BuildContext context, MediaEntity media) {
    final theme = Theme.of(context);

    final count = _mediaCountBox.get(media.id, defaultValue: 0);

    scrollableBottomSheet(
      context: context,
      builder: (context) => [
        Text("媒体信息", style: theme.textTheme.titleMedium),
        ListCard(
          children: [
            ListItem(title: "标题", desc: media.title),
            ListItem(title: "艺术家", desc: media.artist ?? "未知艺术家"),
            ListItem(title: "专辑", desc: media.album ?? "未知专辑"),
            ListItem(title: "音轨号", desc: (media.track ?? "未知专辑").toString()),
          ],
        ),
        ListCard(
          children: [
            ListItem(title: "播放次数", desc: count.toString()),
            ListItem(
              title: "时长",
              desc: CommonHelper.buildDuration(
                Duration(milliseconds: media.duration ?? 0),
              ).data,
            ),
            ListItem(
              title: "比特率",
              desc: media.bitRate != null
                  ? "${(media.bitRate! / 1000).round()}kbps"
                  : "-",
            ),
            ListItem(
              title: "采样率",
              desc: media.sampleRate != null ? "${media.sampleRate}Hz" : "-",
            ),
            ListItem(
              title: "位深",
              desc: media.bitDepth != null ? media.bitDepth.toString() : "-",
            ),
          ],
        ),
        ListCard(
          children: [
            ListItem(title: "路径", desc: media.data),
            FutureBuilder(
              future: File(media.data).stat(),
              builder: (context, snapshot) => ListItem(
                title: "文件大小",
                desc: snapshot.data != null
                    ? filesize(snapshot.data!.size)
                    : "-",
              ),
            ),
            ListItem(title: "文件格式", desc: mime(media.data)),
            ListItem(
              title: "添加时间",
              desc: media.dateAdded != null
                  ? DateUtil.formatDateMs(
                      media.dateAdded! * 1000,
                      format: DateFormats.full,
                    )
                  : "-",
            ),
            ListItem(
              title: "修改时间",
              desc: media.dateModified != null
                  ? DateUtil.formatDateMs(
                      media.dateModified! * 1000,
                      format: DateFormats.full,
                    )
                  : "-",
            ),
          ],
        ),
      ],
    );
  }
}
