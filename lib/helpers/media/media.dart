import "dart:async";
import "dart:io";

import "package:IceyPlayer/event_bus/event_bus.dart";
import "package:audio_query/audio_query.dart";
import "package:IceyPlayer/constants/box_key.dart";
import "package:IceyPlayer/constants/cache_key.dart";
import "package:IceyPlayer/entities/media.dart";
import "package:IceyPlayer/helpers/media_scanner/media_sort.dart";
import "package:IceyPlayer/helpers/toast/toast.dart";
import "package:IceyPlayer/models/media/media.dart";
import "package:hive_ce/hive.dart";
import "package:flutter/material.dart";
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
      List<MediaEntity> _medias = medias ?? _mediaBox.values.toList().cast();

      _medias = sortMedia(_medias, sortType);

      final List<String> filterDir = _settingsBox.get(
        CacheKey.Settings.filterDir,
        defaultValue: <String>[],
      );

      _medias = _medias
          .where((media) => filterDir.every((dir) => !media.data.contains(dir)))
          .toList();

      if (init != true) {
        mediaManager.setLocalMediaList(_medias);
      }

      return _medias;
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
            mediaManager.removeQueue(queueIndex, noToast: true).then((_) async {
              mediaManager.skipToNext();

              final medias = await MediaHelper.queryLocalMedia();

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
    final _sortType = MediaSort.getByValue(sortType);

    medias.sort((a, b) {
      if (_sortType == MediaSort.artist) {
        final aArtist = PinyinHelper.getPinyinE(a.artist!);
        final bArtist = PinyinHelper.getPinyinE(b.artist!);

        return aArtist.compareTo(bArtist);
      } else if (_sortType == MediaSort.title) {
        final aTitle = PinyinHelper.getPinyinE(a.title).toLowerCase();
        final bTitle = PinyinHelper.getPinyinE(b.title).toLowerCase();

        return aTitle.compareTo(bTitle);
      }
      /// 添加时间
      else if (_sortType == MediaSort.addTime) {
        return (a.dateAdded ?? 0).compareTo(b.dateAdded ?? 0);
      } else if (_sortType == MediaSort.addTimeDesc) {
        return (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0);
      }
      /// 添加时间 END
      /// 修改时间
      else if (_sortType == MediaSort.modifyTime) {
        return (a.dateModified ?? 0).compareTo(b.dateModified ?? 0);
      } else if (_sortType == MediaSort.modifyTimeDesc) {
        return (b.dateModified ?? 0).compareTo(a.dateModified ?? 0);
      }
      /// 修改时间 END
      /// 时长
      else if (_sortType == MediaSort.duration) {
        return (a.duration ?? 0).compareTo(b.duration ?? 0);
      } else if (_sortType == MediaSort.durationDesc) {
        return (b.duration ?? 0).compareTo(a.duration ?? 0);
      }
      /// 播放次数
      else if (_sortType == MediaSort.count) {
        final int aCount = _mediaCountBox.get(a.id, defaultValue: 0),
            bCount = _mediaCountBox.get(b.id, defaultValue: 0);

        return aCount.compareTo(bCount);
      } else if (_sortType == MediaSort.countDesc) {
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
}
