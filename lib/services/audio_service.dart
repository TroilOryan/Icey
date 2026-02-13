import 'package:audio_service/audio_service.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/constants/cache_key.dart';
import 'package:IceyPlayer/services/play_mode.dart';

import 'audio_session.dart';
import 'custom_shuffle_order.dart';

class AudioServiceHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  final _settingsBox = Boxes.settingsBox;

  late final _playlist = ConcatenatingAudioSource(
    children: [],
    shuffleOrder: CustomShuffleOrder(),
    useLazyPreparation: true,
  );

  final List<int> _preferredCompactNotificationButtons = [0, 1, 2];

  bool get isPlaying => _player.playing;

  Duration get position => _player.position;

  Stream<Duration> get positionStream => _player.positionStream;

  final audioSessionHandler = AudioSessionHandler();

  AudioServiceHandler() {
    _listenForPositionChanges();
    _listenForCurrentSongIndexChanges();
    _listenForDurationChanges();
    _listenForSequenceStateChanges();
    _notifyAudioHandlerAboutPlaybackEvents();
  }

  Future<void> loadPlaylist(List<MediaItem> mediaItems) async {
    if (mediaItems.isEmpty) {
      await _player.setAudioSource(_playlist, preload: true);

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

      await _player.setAudioSource(
        _playlist,
        initialIndex: initialIndex,
        initialPosition: Duration(milliseconds: position),
        preload: true,
      );
    });

    mediaManager.togglePlayerMode(
      mode: PlayMode.getByValue(
        _settingsBox.get(
          CacheKey.Settings.playMode,
          defaultValue: PlayMode.listLoop.value,
        ),
      ),
      noToast: true,
    );
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }

  void _listenForPositionChanges() {
    _player.positionStream.listen((position) {
      if (position.inMilliseconds == 0) return;

      mediaManager.setPosition(position);

      _settingsBox.put(
        CacheKey.Settings.currentPosition,
        position.inMilliseconds,
      );

      if (mediaItem.value == null || mediaItem.value?.duration == null) return;

      final gap =
          (position.inMilliseconds - mediaItem.value!.duration!.inMilliseconds)
              .abs();

      // 播完一首才算播放次数
      if (mediaItem.value != null && mediaItem.value!.duration != null) {
        if (gap <= 50) {
          final _mediaCountBox = Boxes.mediaCountBox;

          final id = int.parse(mediaItem.value!.id);

          final currentCount = _mediaCountBox.get(id, defaultValue: 0);

          _mediaCountBox.put(id, currentCount + 1);
        }
      }
    });
  }

  Future<void> _listenForCurrentSongIndexChanges() async {
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;

      if (index == null || playlist.isEmpty || index > playlist.length - 1) {
        return;
      }

      if (_player.shuffleModeEnabled) {
        index = (_player.shuffleIndices).indexOf(index);
      }

      if (index != -1) {
        final currentMedia = playlist[index];

        mediaManager.setCurrentMediaItem(currentMedia);

        mediaItem.add(currentMedia);

        _settingsBox.put(CacheKey.Settings.currentMedia, currentMedia.id);
      }
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      int? index = _player.currentIndex;
      final newQueue = queue.value;

      if (newQueue.isEmpty || index == null) return;

      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices.indexOf(index);
      }

      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);

      newQueue[index] = newMediaItem;

      queue.add(newQueue);
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

    if (playing) {
      audioSessionHandler.setActive(true);
    }

    // bool liked = false;
    // if (mediaItem.value != null) {
    //   liked = checkPlaylist('Favorite Songs', mediaItem.value!.id);
    // }

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
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    final audioSource = mediaItems.map(_createAudioSource);
    await _playlist.addAll(audioSource.toList());

    final newQueue = queue.value..addAll(mediaItems);

    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    // manage Just Audio
    final audioSource = _createAudioSource(mediaItem);
    _playlist.add(audioSource);

    // notify system
    final newQueue = queue.value..add(mediaItem);
    queue.add(newQueue);
  }

  @override
  Future<void> updateQueue(List<MediaItem> mediaItems) async {
    _playlist.clear();
    queue.value.clear();

    final audioSource = mediaItems.map(_createAudioSource);

    await _playlist.addAll(audioSource.toList());

    queue.value.addAll(mediaItems);

    queue.add(mediaItems);
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    final _queue = List<MediaItem>.from(queue.value);

    _playlist.insert(index, _createAudioSource(mediaItem));

    final newQueue = _queue..insert(index, mediaItem);

    queue.add(newQueue);
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = queue.value.indexOf(mediaItem);
    // manage Just Audio
    _playlist.removeAt(index);

    // notify system
    final newQueue = queue.value..removeAt(index);
    queue.add(newQueue);
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) => AudioSource.uri(
    Uri.parse(mediaItem.extras!['uri'] as String),
    tag: mediaItem,
  );

  @override
  Future<void> removeQueueItemAt(int index) async {
    // manage Just Audio
    _playlist.removeAt(index);

    // notify system
    final newQueue = queue.value..removeAt(index);
    queue.add(newQueue);
  }

  @override
  Future<void> updateMediaItem(MediaItem newMediaItem) async {
    mediaItem.add(newMediaItem);
  }

  @override
  Future<void> play() async {
    _player.play();
  }

  @override
  Future<void> pause() async {
    _player.pause();
  }

  @override
  Future<void> seek(Duration position, {int? index}) =>
      _player.seek(position, index: index);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    if (_player.shuffleModeEnabled) {
      index = _player.shuffleIndices![index];
    }

    _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() async {
    if (_player.loopMode == LoopMode.one && mediaItem.value != null) {
      final index = queue.value.indexOf(mediaItem.value!);

      skipToQueueItem(index == queue.value.length - 1 ? 0 : index + 1);
      _player.play();
      return;
    }

    _player.seekToNext();
    _player.play();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.loopMode == LoopMode.one && mediaItem.value != null) {
      final index = queue.value.indexOf(mediaItem.value!);

      skipToQueueItem(index == 0 ? queue.value.length - 1 : index - 1);
      _player.play();
      return;
    }

    _player.seekToPrevious();
    _player.play();
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;

    if (enabled) {
      await _player.shuffle();
    }

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
    await _player.setLoopMode(LoopMode.values[repeatMode.index]);
  }

  @override
  Future<void> stop() async {
    // await _player.stop();
    // await _player.dispose();

    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
