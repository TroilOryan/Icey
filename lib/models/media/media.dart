import 'dart:typed_data';

import 'package:IceyPlayer/helpers/media/media.dart';
import 'package:IceyPlayer/helpers/platform.dart';
import 'package:IceyPlayer/models/lyric/lyric.dart';
import 'package:IceyPlayer/src/rust/api/tag_reader.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:IceyPlayer/components/play_lyric_source/play_lyric_source.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/constants/cache_key.dart';
import 'package:IceyPlayer/entities/album.dart';
import 'package:IceyPlayer/entities/artist.dart';
import 'package:IceyPlayer/entities/media.dart';
import 'package:IceyPlayer/helpers/toast/toast.dart';
import 'package:IceyPlayer/services/audio_service.dart';
import 'package:IceyPlayer/services/media_state.dart';
import 'package:IceyPlayer/services/play_mode.dart';
import 'package:signals/signals.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:window_manager/window_manager.dart';

final mediaManager = MediaManager();

final _mediaBox = Boxes.mediaBox;

final _settingsBox = Boxes.settingsBox;

class CoverColor {
  final int primary;
  final int secondary;
  final bool isDark;

  const CoverColor({
    required this.primary,
    required this.secondary,
    required this.isDark,
  });
}

class MediaManager {
  final Signal<Duration> _position;

  /// 扫描出来的所有媒体
  /// 切换屏蔽文件夹的时候 可能会变少
  final Signal<List<MediaEntity>> _localMediaList;

  /// 用于展示的媒体列表
  final Signal<List<MediaEntity>> _mediaList;
  late final Computed<List<AlbumEntity>> _albumList;
  late final Computed<List<ArtistEntity>> _artistList;
  final Signal<MediaItem?> _currentMediaItem;
  final Signal<bool> _isPlaying;
  late final AudioServiceHandler _audioService;
  final Signal<CoverColor> _coverColor;
  final Signal<Uint8List> _currentCover;
  final Signal<PlayMode> _playMode;

  Signal<Duration> get position => _position;

  Stream<Duration> get positions => _audioService.positionStream;

  Signal<List<MediaEntity>> get localMediaList => _localMediaList;

  Signal<List<MediaEntity>> get mediaList => _mediaList;

  Computed<List<AlbumEntity>> get albumList => _albumList;

  Computed<List<ArtistEntity>> get artistList => _artistList;

  Signal<MediaItem?> get currentMediaItem => _currentMediaItem;

  Signal<bool> get isPlaying => _isPlaying;

  Signal<CoverColor> get coverColor => _coverColor;

  Signal<Uint8List> get currentCover => _currentCover;

  Signal<PlayMode> get playMode => _playMode;

  rx.BehaviorSubject<MediaItem?> get mediaItem => _audioService.mediaItem;

  rx.BehaviorSubject<List<MediaItem>> get queue => _audioService.queue;

  rx.BehaviorSubject<PlaybackState> get playbackState =>
      _audioService.playbackState;

  Stream<MediaState> get mediaStateStream =>
      rx.Rx.combineLatest2<MediaItem?, Duration, MediaState>(
        mediaItem,
        AudioService.position,
        (mediaItem, position) =>
            MediaState(mediaItem: mediaItem, position: position),
      );

  MediaManager()
    : _position = signal(Duration.zero),
      _localMediaList = signal([]),
      _mediaList = signal([]),
      _currentMediaItem = signal(null),
      _isPlaying = signal(false),
      _coverColor = signal(
        const CoverColor(primary: -1, secondary: -1, isDark: false),
      ),
      _currentCover = signal(Uint8List(0)),
      _playMode = signal(PlayMode.listLoop) {
    _playMode.value = PlayMode.getByValue(
      _settingsBox.get(
        CacheKey.Settings.playMode,
        defaultValue: PlayMode.listLoop.value,
      ),
    );

    _albumList = computed(() {
      final Map<String, List<MediaEntity>> albumGroups = {};
      final Map<String, String> albumNames = {};

      for (final media in _mediaList.value) {
        final albumId = (media.albumID ?? BigInt.from(-1)).toString();
        albumGroups.putIfAbsent(albumId, () => []).add(media);
        albumNames.putIfAbsent(albumId, () => media.album ?? "未知专辑");
      }

      return List.unmodifiable(
        albumGroups.entries.map(
          (e) => AlbumEntity(
            id: e.key,
            name: albumNames[e.key]!,
            mediaIDs: e.value.map((m) => m.id).toList(),
          ),
        ),
      );
    });

    _artistList = computed(() {
      final Map<String, List<MediaEntity>> artistGroups = {};
      final Map<String, String> artistNames = {};

      for (final media in _mediaList.value) {
        final artistId = (media.artistID ?? BigInt.from(-1)).toString();
        artistGroups.putIfAbsent(artistId, () => []).add(media);
        artistNames.putIfAbsent(artistId, () => media.artist ?? "未知艺术家");
      }

      return List.unmodifiable(
        artistGroups.entries.map(
          (e) => ArtistEntity(
            id: e.key,
            name: artistNames[e.key]!,
            mediaIDs: e.value.map((m) => m.id).toList(),
          ),
        ),
      );
    });
  }

  void init({
    required List<MediaEntity> medias,
    required AudioServiceHandler audioService,
  }) {
    _audioService = audioService;
    setLocalMediaList(medias, true);
  }

  void setPosition(Duration value) {
    _position.value = value;

    lyricManager.setCurrentIndexByPosition(value);
  }

  void setLocalMediaList(List<MediaEntity> value, [bool? local]) {
    _mediaList.value = List.unmodifiable(value);

    if (local == true) {
      _localMediaList.value = value;
    }
  }

  // 切换播放模式
  void togglePlayerMode({PlayMode? mode, bool? noToast}) {
    if (mode != null) {
      _playMode.value = mode;
    } else {
      const l = [
        PlayMode.singleLoop,
        PlayMode.listLoop,
        PlayMode.random,
        PlayMode.listOrder,
      ];

      final int index = l.indexWhere((p) => _playMode.value == p);

      if (index == l.length - 1) {
        _playMode.value = l[0];
      } else {
        _playMode.value = l[index + 1];
      }
    }

    if (noToast != true) {
      showToast("${_playMode.value.name}模式");
    }

    _audioService.setPlayMode(_playMode.value);

    _settingsBox.put(CacheKey.Settings.playMode, _playMode.value.value);
  }

  Future<void> updateQueue(List<MediaItem> value) async {
    await _audioService.updateQueue(value);
  }

  Future<void> loadPlaylist(List<MediaItem> value) async {
    await _audioService.loadPlaylist(value);
  }

  void addToQueue(int index, MediaEntity media) {
    _audioService.insertQueueItem(index, MediaEntity.toMediaItem(media));

    showToast("已添加到播放列表");
  }

  void addQueueItems(List<MediaItem> value) {
    _audioService.addQueueItems(value);
  }

  Future<void> removeQueue(int index, {bool? noToast}) async {
    await _audioService.removeQueueItemAt(index);

    if (noToast != true) {
      showToast("已从播放列表移除");
    }
  }

  void removeQueueItem(MediaItem media) {
    _audioService.removeQueueItem(media);
  }

  void setIsPlaying(bool value) {
    _isPlaying.value = value;
  }

  void pause() {
    _audioService.pause();
  }

  void play([String? id]) {
    if (id != null) {
      final index = _audioService.queue.value.indexWhere(
        (item) => item.id == id,
      );

      if (index != -1) {
        _audioService.skipToQueueItem(index);
      }
    }

    if (mediaManager.isPlaying.value &&
        id == _audioService.mediaItem.value?.id) {
      _audioService.pause();
    } else {
      _audioService.play();
    }
  }

  void skipToPrevious() {
    _audioService.skipToPrevious();
  }

  void skipToNext() {
    _audioService.skipToNext();
  }

  void rewind() {
    _audioService.rewind();
  }

  void fastForward() {
    _audioService.fastForward();
  }

  void skipToQueueItem(int index) {
    _audioService.skipToQueueItem(index);
  }

  void seek(Duration position) {
    _audioService.seek(position);
  }

  Future<void> setCurrentMediaItem(MediaItem value) async {
    if (value.id == _currentMediaItem.value?.id) {
      return;
    }

    if (PlatformHelper.isDesktop) {
      windowManager.setTitle(value.title);
    }

    batch(() async {
      final String path = value.extras?["path"];

      _currentMediaItem.value = value;

      final res = await getLyricFromPath(path: path);

      if (res == null) {
        lyricManager.setLyricModel("");

        lyricManager.setLyricSource(LyricSource.none);
      } else {
        lyricManager.setLyricModel(res.lyrics);

        lyricManager.setLyricSource(LyricSource.getByValue(res.source));
      }

      try {
        final coverRes = await MediaHelper.queryCover(value.extras?["path"]);

        _currentCover.value = coverRes?.cover ?? Uint8List(0);

        if (coverRes != null) {
          _coverColor.value = CoverColor(
            primary: coverRes.primary,
            secondary: coverRes.secondary,
            isDark: coverRes.isDark,
          );
        } else {
          _coverColor.value = const CoverColor(
            primary: -1,
            secondary: -1,
            isDark: false,
          );
        }
      } catch (e) {
        _currentCover.value = Uint8List(0);

        _coverColor.value = const CoverColor(
          primary: -1,
          secondary: -1,
          isDark: false,
        );
      }
    });
  }
}
