import 'package:audio_service/audio_service.dart';

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  const MediaState({required this.mediaItem, required this.position});
}
