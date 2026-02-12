import 'package:just_audio/just_audio.dart';

import 'custom_shuffle_order.dart';

class AudioServiceWindowsHandler {
  final _player = AudioPlayer();

  late final _playlist = ConcatenatingAudioSource(
    children: [],
    shuffleOrder: CustomShuffleOrder(),
    useLazyPreparation: true,
  );

  AudioServiceWindowsHandler() {
    _listenForPositionChanges();
  }

  void _listenForPositionChanges() {}
}
