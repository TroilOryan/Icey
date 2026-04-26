import "dart:async";
import "dart:io";

import "package:IceyPlayer/event_bus/event_bus.dart";
import "package:IceyPlayer/src/rust/api/tag_reader.dart";
import "package:audio_query/audio_query.dart";
import "package:IceyPlayer/constants/box_key.dart";
import "package:IceyPlayer/constants/cache_key.dart";
import "package:IceyPlayer/entities/media.dart";
import "package:IceyPlayer/helpers/media_scanner/media_sort.dart";
import "package:IceyPlayer/helpers/toast/toast.dart";
import "package:IceyPlayer/models/media/media.dart";
import "package:pinyin/pinyin.dart";
import "package:uuid/uuid.dart";

late final Directory appCacheDir;

const Uuid uuid = Uuid();

final _mediaBox = Boxes.mediaBox,
    _settingsBox = Boxes.settingsBox,
    _mediaCountBox = Boxes.mediaCountBox,
    _likedBox = Boxes.likedBox;

class MediaHelper {
  /// 获取本地
  static List<MediaEntity> queryLocalMedia({
    List<MediaEntity>? medias,
    bool? init,
  }) {
    final sortType = _settingsBox.get(
      CacheKey.Settings.sortType,
      defaultValue: 1,
    );

    try {
      List<MediaEntity> medias0 = medias ?? _mediaBox.values.toList().cast();

      medias0 = sortMedia(medias0, sortType);

      final List<String> filterDir = _settingsBox.get(
        CacheKey.Settings.filterDir,
        defaultValue: <String>[],
      );

      medias0 = medias0
          .where((media) => filterDir.every((dir) => !media.data.contains(dir)))
          .toList();

      if (init != true) {
        mediaManager.setLocalMediaList(medias0);
      }

      return medias0;
    } catch (error) {
      return [];
    }
  }

  static MediaEntity? queryMedia(String? id) {
    if (id == null) {
      return null;
    }

    return _mediaBox.get(id);
  }

  static Future deleteMedia(MediaEntity media) async {
    try {
      final result = await AudioQuery().deleteMediaFile(media.data);

      if (result) {
        final index = _mediaBox.values.toList().indexWhere(
          (item) => item.id == media.id,
        );

        if (index != -1) {
          await _mediaBox.deleteAt(index);

          final queueIndex = mediaManager.queue.value.indexWhere(
            (e) => e.id == media.id,
          );

          if (queueIndex != -1) {
            if (mediaManager.mediaItem.value != null &&
                media.id == mediaManager.mediaItem.value!.id) {
              mediaManager.skipToNext();
            }

            mediaManager.removeQueue(queueIndex, noToast: true).then((_) async {
              final medias = MediaHelper.queryLocalMedia();

              mediaManager.setLocalMediaList(medias, true);

              showToast("删除成功");
            });
          }
        }
      } else {
        showToast("删除失败");
      }
    } catch (e) {
      showToast("删除失败");
    }
  }

  static List<MediaEntity> sortMedia(List<MediaEntity> medias, int sortType) {
    final sortType0 = MediaSort.getByValue(sortType);

    medias.sort((a, b) {
      if (sortType0 == MediaSort.artist) {
        final aArtist = PinyinHelper.getPinyinE(a.artist!);
        final bArtist = PinyinHelper.getPinyinE(b.artist!);

        return aArtist.compareTo(bArtist);
      } else if (sortType0 == MediaSort.title) {
        final aTitle = PinyinHelper.getPinyinE(a.title).toLowerCase();
        final bTitle = PinyinHelper.getPinyinE(b.title).toLowerCase();

        return aTitle.compareTo(bTitle);
      }
      /// 添加时间
      else if (sortType0 == MediaSort.addTime) {
        return (a.dateAdded ?? 0).compareTo(b.dateAdded ?? 0);
      } else if (sortType0 == MediaSort.addTimeDesc) {
        return (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0);
      }
      /// 添加时间 END
      /// 修改时间
      else if (sortType0 == MediaSort.modifyTime) {
        return (a.dateModified ?? 0).compareTo(b.dateModified ?? 0);
      } else if (sortType0 == MediaSort.modifyTimeDesc) {
        return (b.dateModified ?? 0).compareTo(a.dateModified ?? 0);
      }
      /// 修改时间 END
      /// 时长
      else if (sortType0 == MediaSort.duration) {
        return (a.duration ?? 0).compareTo(b.duration ?? 0);
      } else if (sortType0 == MediaSort.durationDesc) {
        return (b.duration ?? 0).compareTo(a.duration ?? 0);
      }
      /// 播放次数
      else if (sortType0 == MediaSort.count) {
        final int aCount = _mediaCountBox.get(a.id, defaultValue: 0),
            bCount = _mediaCountBox.get(b.id, defaultValue: 0);

        return aCount.compareTo(bCount);
      } else if (sortType0 == MediaSort.countDesc) {
        final int aCount = _mediaCountBox.get(a.id, defaultValue: 0),
            bCount = _mediaCountBox.get(b.id, defaultValue: 0);

        return bCount.compareTo(aCount);
      }
      /// 播放次数 END
      /// 时长 END
      else {
        final aTitle = PinyinHelper.getPinyinE(a.title).toLowerCase();
        final bTitle = PinyinHelper.getPinyinE(b.title).toLowerCase();

        return aTitle.compareTo(bTitle);
      }
    });

    return medias;
  }

  static Future<bool> likeMedia(String? id, bool liked) async {
    if (id == null) {
      return liked;
    }

    if (liked) {
      _likedBox.delete(id);
    } else {
      _likedBox.put(id, true);
    }

    eventBus.fire(LikeMediaChange(id, !liked));

    return !liked;
  }

  static Future<ArtworkColorResult?> queryCover(String id) async {
    final res = await getArtworkColor(path: id);

    return res;

    // if (PlatformHelper.isDesktop) {
    //   final res = await getArtworkFromPath(path: id, width: 1024, height: 1024);
    //
    //   return {"cover": res};
    // } else {
    //   final coverRes = await AudioQuery().queryArtworkWithColor(
    //     id,
    //     ArtworkType.AUDIO,
    //     size: 1024,
    //   );
    //
    //   return coverRes;
    // }
  }
}
