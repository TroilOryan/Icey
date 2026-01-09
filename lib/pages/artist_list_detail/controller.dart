import 'package:IceyPlayer/entities/media.dart';
import 'package:IceyPlayer/models/media/media.dart';

class ArtistListDetailController {
  void handlePlayAll(List<MediaEntity> mediaList) {
    if (mediaList.isEmpty) return;

    mediaManager.updateQueue(mediaList.map(MediaEntity.toMediaItem).toList());

    mediaManager.skipToQueueItem(0);
  }
}
