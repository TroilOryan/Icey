import 'dart:async';
import 'dart:io';

import 'package:IceyPlayer/helpers/common.dart';
import 'package:IceyPlayer/helpers/overlay/overlay.dart';
import 'package:IceyPlayer/helpers/platform.dart';
import 'package:audio_service/audio_service.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:just_audio/just_audio.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/constants/cache_key.dart';
import 'package:IceyPlayer/services/play_mode.dart';

import 'audio_session.dart';
import 'custom_shuffle_order.dart';

class AudioServiceHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  final _settingsBox = Boxes.settingsBox;

  /// 自管理的播放队列，反映实际播放顺序
  /// shuffle 开启时为打乱顺序，关闭时为原始顺序
  final List<MediaItem> _queue = [];

  /// 当前歌曲在 _queue 中的索引
  int _currentQueueIndex = 0;

  /// 手动跳转标志，防止 currentIndexStream 重复处理
  bool _isManuallyAdvancing = false;

  /// 手动跳转超时保护
  Timer? _manualAdvanceTimer;

  late final _playlist = ConcatenatingAudioSource(
    children: [],
    shuffleOrder: CustomShuffleOrder(),
    useLazyPreparation: true,
  );

  final List<int> _preferredCompactNotificationButtons = [0, 1, 2];

  Duration get position => _player.position;

  Stream<Duration> get positionStream => _player.positionStream;

  Timer? overlayVisibleTimer;
  Timer? positionUpdateTimer;
  int lastPosition = 0;

  final audioSessionHandler = AudioSessionHandler();

  AudioServiceHandler() {
    _listenForPositionChanges();
    _listenForCurrentSongIndexChanges();
    _listenForDurationChanges();
    _listenForSequenceStateChanges();
    _notifyAudioHandlerAboutPlaybackEvents();
  }

  /// 同步内部 _queue 到 BaseAudioHandler 的 queue stream
  void _syncQueueToStream() {
    queue.add(List.unmodifiable(_queue));
  }

  /// 将 queue 索引映射为 _playlist 序列索引
  int _queueIndexToSequenceIndex(int queueIndex) {
    if (queueIndex < 0 || queueIndex >= _queue.length) return 0;
    final mediaItemTag = _queue[queueIndex];
    for (int i = 0; i < _playlist.length; i++) {
      if ((_playlist[i] as IndexedAudioSource).tag == mediaItemTag) return i;
    }
    return 0;
  }

  /// 重置手动跳转标志
  void _resetManualAdvance() {
    _isManuallyAdvancing = false;
    _manualAdvanceTimer?.cancel();
  }

  Future<void> loadPlaylist(List<MediaItem> mediaItems) async {
    if (PlatformHelper.isDesktop) {
      final List<MediaItem> arr = [];

      final dir = Directory('${CommonHelper.tmpDir.path}/IceyCover');

      if (!await dir.exists()) {
        await dir.create();
      }

      for (MediaItem mediaItem in mediaItems) {
        String tmpPath = "${dir.path}/${mediaItem.title}.jpg";

        final tmpFile = File(tmpPath);

        if (await tmpFile.exists()) {
          arr.add(mediaItem.copyWith(artUri: tmpFile.uri));
        } else {
          arr.add(mediaItem);
        }
      }

      mediaItems = arr;
    }

    setPlayMode(
      PlayMode.getByValue(
        _settingsBox.get(
          CacheKey.Settings.playMode,
          defaultValue: PlayMode.listLoop.value,
        ),
      ),
    );

    if (mediaItems.isEmpty) {
      if (!PlatformHelper.isDesktop) {
        await _player.setAudioSource(_playlist, preload: true);

        FlutterNativeSplash.remove();
      } else {
        _player.setAudioSources([], preload: true);
      }

      return;
    }

    updateQueue(mediaItems).then((res) async {
      final String? currentMediaID = _settingsBox.get(
        CacheKey.Settings.currentMedia,
        defaultValue: null,
      );

      final int position = _settingsBox.get(
        CacheKey.Settings.currentPosition,
        defaultValue: 0,
      );

      final int index = mediaItems.indexWhere(
        (element) => element.id == currentMediaID,
      );

      final initialIndex = index == -1 ? 0 : index;

      if (PlatformHelper.isDesktop) {
        _player.setAudioSources(
          mediaItems
              .where((e) => e.extras?["path"] != null)
              .map((e) => AudioSource.file(e.extras!["path"], tag: e))
              .toList(),
          initialIndex: initialIndex,
          initialPosition: Duration(milliseconds: position),
          preload: true,
        );
      } else {
        await _player.setAudioSource(
          _playlist,
          initialIndex: initialIndex,
          initialPosition: Duration(milliseconds: position),
          preload: true,
        );
      }

      // 根据初始播放的歌曲找到 queue 中的位置
      if (currentMediaID != null) {
        final queueIndex = _queue.indexWhere((e) => e.id == currentMediaID);
        if (queueIndex != -1) {
          _currentQueueIndex = queueIndex;
        }
      }

      if (!PlatformHelper.isDesktop) {
        FlutterNativeSplash.remove();
      }
    });
  }

  /// 监听 sequenceState 变化，重建 _queue
  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;

      final newShuffleEnabled = sequenceState!.shuffleModeEnabled;
      final newShuffleIndices = sequenceState.shuffleIndices.toList();
      final newSequenceLength = sequence.length;

      // 仅在 shuffle 状态或序列长度变化时重建 queue
      final needRebuild = newShuffleEnabled != _lastShuffleEnabled ||
          newShuffleIndices.toString() != _lastShuffleIndices.toString() ||
          newSequenceLength != _lastSequenceLength;

      if (!needRebuild) return;

      _lastShuffleEnabled = newShuffleEnabled;
      _lastShuffleIndices = newShuffleIndices;
      _lastSequenceLength = newSequenceLength;

      // 保留已有 item 的 duration 数据
      final Map<String, MediaItem> existingItems = {};
      for (final item in _queue) {
        existingItems[item.id] = item;
      }

      _queue.clear();
      for (final source in sequence) {
        final tag = source.tag as MediaItem;
        final existing = existingItems[tag.id];
        _queue.add(existing ?? tag);
      }

      _syncQueueToStream();

      // 找到当前歌曲在新 queue 中的位置
      final currentItem = mediaItem.value;
      if (currentItem != null) {
        final idx = _queue.indexWhere((item) => item.id == currentItem.id);
        if (idx != -1) {
          _currentQueueIndex = idx;
        }
      }
    });
  }

  bool _lastShuffleEnabled = false;
  List<int> _lastShuffleIndices = [];
  int _lastSequenceLength = 0;

  void _listenForPositionChanges() {
    _player.positionStream.listen((position) {
      // 自动推进：歌曲播完时跳到 queue 中的下一首
      if (!_isManuallyAdvancing &&
          position.inMilliseconds > 0 &&
          mediaItem.value?.duration != null) {
        final gap =
            (position.inMilliseconds -
                    mediaItem.value!.duration!.inMilliseconds)
                .abs();

        if (gap <= 50) {
          _autoAdvanceIfNeeded();
        }
      }

      if (position.inMilliseconds == 0) return;

      mediaManager.setPosition(position);

      // 每1秒写入一次数据库，减少数据库操作频率
      if (positionUpdateTimer == null || !positionUpdateTimer!.isActive) {
        positionUpdateTimer = Timer(const Duration(seconds: 1), () {
          if (position.inMilliseconds != lastPosition) {
            _settingsBox.put(
              CacheKey.Settings.currentPosition,
              position.inMilliseconds,
            );
            lastPosition = position.inMilliseconds;
          }
        });
      }

      if (mediaItem.value == null || mediaItem.value?.duration == null) return;

      final gap =
          (position.inMilliseconds - mediaItem.value!.duration!.inMilliseconds)
              .abs();

      // 播完一首才算播放次数
      if (mediaItem.value != null && mediaItem.value!.duration != null) {
        if (gap <= 50) {
          final _mediaCountBox = Boxes.mediaCountBox;

          final id = mediaItem.value!.id;

          final currentCount = _mediaCountBox.get(id, defaultValue: 0);

          _mediaCountBox.put(id, currentCount + 1);
        }
      }
    });
  }

  /// 歌曲自然播完时，跳到 queue 中的下一首
  void _autoAdvanceIfNeeded() {
    if (_queue.isEmpty) return;

    // 确认当前播放的确实是 queue 中预期的歌曲
    final currentIndex = _player.currentIndex;
    if (currentIndex != null) {
      final playingTag = (_playlist[currentIndex] as IndexedAudioSource).tag;
      if (playingTag != _queue[_currentQueueIndex]) return;
    }

    if (_currentQueueIndex < _queue.length - 1) {
      _currentQueueIndex++;
      final seqIndex = _queueIndexToSequenceIndex(_currentQueueIndex);
      _isManuallyAdvancing = true;
      _player.seek(Duration.zero, index: seqIndex);

      // 超时保护：5秒后重置标志
      _manualAdvanceTimer?.cancel();
      _manualAdvanceTimer = Timer(const Duration(seconds: 5), () {
        _isManuallyAdvancing = false;
      });
    }
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      if (_isManuallyAdvancing) {
        _resetManualAdvance();
        return;
      }

      if (index == null || _queue.isEmpty) return;

      // currentIndex 是 _playlist 的序列索引，需映射到 _queue
      if (index < _playlist.length) {
        final tag = (_playlist[index] as IndexedAudioSource).tag;
        final queueIdx = _queue.indexWhere((item) => item.id == tag.id);
        if (queueIdx != -1) {
          _currentQueueIndex = queueIdx;
        }
      }

      if (_currentQueueIndex >= _queue.length) return;

      final currentMedia = _queue[_currentQueueIndex];

      mediaManager.setCurrentMediaItem(currentMedia);

      mediaItem.add(currentMedia);

      _settingsBox.put(CacheKey.Settings.currentMedia, currentMedia.id);
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      final index = _player.currentIndex;

      if (_queue.isEmpty || index == null || index >= _playlist.length) return;

      // 通过 tag 匹配找到 _queue 中对应的 item
      final tag = (_playlist[index] as IndexedAudioSource).tag;
      final queueIdx = _queue.indexWhere((item) => item.id == tag.id);
      if (queueIdx == -1) return;

      final newMediaItem = _queue[queueIdx].copyWith(duration: duration);

      _queue[queueIdx] = newMediaItem;

      _syncQueueToStream();
      mediaItem.add(newMediaItem);
    });
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen(_broadcastState);
  }

  void setPlayMode(PlayMode playMode) {
    switch (playMode) {
      case PlayMode.singleLoop:
        setRepeatMode(AudioServiceRepeatMode.one);
        setShuffleMode(AudioServiceShuffleMode.none);
        break;
      case PlayMode.random:
        setRepeatMode(AudioServiceRepeatMode.all);
        setShuffleMode(AudioServiceShuffleMode.all);
        break;
      case PlayMode.listLoop:
        setRepeatMode(AudioServiceRepeatMode.all);
        setShuffleMode(AudioServiceShuffleMode.none);
        break;
      case PlayMode.listOrder:
        setRepeatMode(AudioServiceRepeatMode.none);
        setShuffleMode(AudioServiceShuffleMode.none);
        break;
      default:
        break;
    }
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;

    OverlayHelper.shareData({"playing": playing});

    if (PlatformHelper.isMobile) {
      mediaManager.setIsPlaying(playing);
    }

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          const MediaControl(
            androidIcon: 'drawable/ic_action_skip_previous',
            label: 'previous',
            action: MediaAction.skipToPrevious,
          ),
          if (playing)
            const MediaControl(
              androidIcon: 'drawable/ic_action_pause',
              label: 'pause',
              action: MediaAction.pause,
            )
          else
            const MediaControl(
              androidIcon: 'drawable/ic_action_play_arrow',
              label: 'play',
              action: MediaAction.play,
            ),
          const MediaControl(
            androidIcon: 'drawable/ic_action_skip_next',
            label: 'next',
            action: MediaAction.skipToNext,
          ),
          // const MediaControl(
          //     androidIcon: 'drawable/ic_action_close',
          //     label: 'close',
          //     action: MediaAction.stop)
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: _preferredCompactNotificationButtons,
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_player.loopMode]!,
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ),
    );

    if (playing) {
      overlayVisibleTimer?.cancel();

      audioSessionHandler.setActive(true);

      OverlayHelper.shareData({"visible": true});
    } else {
      overlayVisibleTimer = Timer(const Duration(milliseconds: 3000), () {
        OverlayHelper.shareData({"visible": false});
      });
    }
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    final audioSource = mediaItems.map(_createAudioSource).toList();
    await _playlist.addAll(audioSource);

    _queue.addAll(mediaItems);
    _syncQueueToStream();
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final audioSource = _createAudioSource(mediaItem);
    _playlist.add(audioSource);

    _queue.add(mediaItem);
    _syncQueueToStream();
  }

  @override
  Future<void> updateQueue(List<MediaItem> mediaItems) async {
    _playlist.clear();
    _queue.clear();

    final audioSource = mediaItems.map(_createAudioSource).toList();

    await _playlist.addAll(audioSource);

    // 如果 shuffle 已启用，按 shuffleIndices 重排 queue
    if (_player.shuffleModeEnabled && _player.shuffleIndices != null) {
      final indices = _player.shuffleIndices!;
      for (int i = 0; i < indices.length && i < mediaItems.length; i++) {
        _queue.add(mediaItems[indices[i]]);
      }
    } else {
      _queue.addAll(mediaItems);
    }

    _syncQueueToStream();

    _resetManualAdvance();
    _currentQueueIndex = 0;
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    // 注意：index 是 queue 中的位置，需要映射到 _playlist
    final seqIndex = _queueIndexToSequenceIndex(index);
    _playlist.insert(seqIndex, _createAudioSource(mediaItem));

    _queue.insert(index, mediaItem);
    _syncQueueToStream();
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = _queue.indexWhere(
      (item) => item.id == mediaItem.id &&
          item.extras?['uuid'] == mediaItem.extras?['uuid'],
    );
    if (index == -1) return;

    await removeQueueItemAt(index);
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    final uri = mediaItem.extras?['uri'] as String?;
    if (uri == null) {
      throw ArgumentError('MediaItem must have a non-null uri in extras');
    }
    return AudioSource.uri(Uri.parse(uri), tag: mediaItem);
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index < 0 || index >= _queue.length) return;

    // 找到该歌曲在 _playlist 中的位置（queue 顺序和 playlist 顺序可能不同）
    final seqIndex = _queueIndexToSequenceIndex(index);

    // 从 _playlist 移除，sequenceStateStream 会自动重建 _queue
    if (seqIndex < _playlist.length) {
      await _playlist.removeAt(seqIndex);
    }
  }

  @override
  Future<void> updateMediaItem(MediaItem newMediaItem) async {
    mediaItem.add(newMediaItem);
  }

  @override
  Future<void> play() async {
    _player.play();

    mediaManager.setIsPlaying(true);
  }

  @override
  Future<void> pause() async {
    _player.pause();

    mediaManager.setIsPlaying(false);
  }

  @override
  Future<void> seek(Duration position, {int? index}) =>
      _player.seek(position, index: index);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _queue.length) return;

    _currentQueueIndex = index;
    final seqIndex = _queueIndexToSequenceIndex(index);

    _isManuallyAdvancing = true;
    _player.seek(Duration.zero, index: seqIndex);

    _manualAdvanceTimer?.cancel();
    _manualAdvanceTimer = Timer(const Duration(seconds: 5), () {
      _isManuallyAdvancing = false;
    });
  }

  @override
  Future<void> skipToNext() async {
    // 单曲循环模式下，skipToNext 强制跳到下一首
    if (_player.loopMode == LoopMode.one) {
      if (_queue.isEmpty) return;
      final nextIndex = _currentQueueIndex < _queue.length - 1
          ? _currentQueueIndex + 1
          : 0;
      await skipToQueueItem(nextIndex);
      play();
      return;
    }

    if (_currentQueueIndex < _queue.length - 1) {
      _currentQueueIndex++;
      final seqIndex = _queueIndexToSequenceIndex(_currentQueueIndex);

      _isManuallyAdvancing = true;
      _player.seek(Duration.zero, index: seqIndex);

      _manualAdvanceTimer?.cancel();
      _manualAdvanceTimer = Timer(const Duration(seconds: 5), () {
        _isManuallyAdvancing = false;
      });

      if (!mediaManager.isPlaying.value) {
        play();
      }
    }
  }

  @override
  Future<void> skipToPrevious() async {
    // 单曲循环模式下，skipToPrevious 强制跳到上一首
    if (_player.loopMode == LoopMode.one) {
      if (_queue.isEmpty) return;
      final prevIndex = _currentQueueIndex > 0
          ? _currentQueueIndex - 1
          : _queue.length - 1;
      await skipToQueueItem(prevIndex);
      play();
      return;
    }

    if (_currentQueueIndex > 0) {
      _currentQueueIndex--;
      final seqIndex = _queueIndexToSequenceIndex(_currentQueueIndex);

      _isManuallyAdvancing = true;
      _player.seek(Duration.zero, index: seqIndex);

      _manualAdvanceTimer?.cancel();
      _manualAdvanceTimer = Timer(const Duration(seconds: 5), () {
        _isManuallyAdvancing = false;
      });

      play();
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;

    // 不调用 _player.shuffle()，保持 _playlist 原始顺序
    // queue 的顺序由 sequenceStateStream 根据 effectiveSequence 自动重建

    playbackState.add(
      playbackState.value.copyWith(
        shuffleMode: shuffleMode,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
      ),
    );

    await _player.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    playbackState.add(
      playbackState.value.copyWith(
        repeatMode: repeatMode,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
      ),
    );

    // 所有模式都用 LoopMode.all，自动推进由 _autoAdvanceIfNeeded 管理
    // 单曲循环例外：使用 LoopMode.one 让 player 自动循环当前歌曲
    if (repeatMode == AudioServiceRepeatMode.one) {
      await _player.setLoopMode(LoopMode.one);
    } else {
      await _player.setLoopMode(LoopMode.all);
    }
  }

  @override
  Future<void> stop() async {
    // 取消计时器
    overlayVisibleTimer?.cancel();
    positionUpdateTimer?.cancel();

    // await _player.stop();
    // await _player.dispose();

    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
