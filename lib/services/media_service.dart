// import 'package:IceyPlayer/constants/box_key.dart';
// import 'package:IceyPlayer/constants/cache_key.dart';
// import 'package:IceyPlayer/models/media/media.dart';
// import 'package:IceyPlayer/services/play_mode.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:signals/signals_flutter.dart';
//
// class MediaService {
//   final _player = Player();
//
//   final _settingsBox = Boxes.settingsBox;
//
//   final isPlaying = signal(false);
//
//   final position = signal(Duration.zero);
//
//   final currentMedia = signal<Media?>(null);
//
//   final currentIndex = signal(-1);
//
//   MediaService() {
//     _listenPlayList();
//     _listenPosition();
//   }
//
//   Future<void> loadPlaylist(List<Media> mediaList) async {
//     if (mediaList.isEmpty) {
//       return;
//     }
//
//     updateQueue(mediaList).then((_) {
//       final int position = _settingsBox.get(
//         CacheKey.Settings.currentPosition,
//         defaultValue: 0,
//       );
//
//       _player.seek(Duration(milliseconds: position));
//     });
//   }
//
//   void _listenPlayList() {
//     _player.stream.playlist.listen((playlist) {
//       if (playlist.index >= 0 && playlist.index < playlist.medias.length) {
//         currentIndex.value = playlist.index;
//         currentMedia.value = playlist.medias[playlist.index];
//
//         // 处理当前媒体信息
//         if (currentMedia.value != null) {
//           print('当前播放: ${currentMedia.value!.uri}');
//           // 访问extras中的自定义元数据
//           Map<String, dynamic>? metadata = currentMedia.value!.extras;
//           if (metadata != null) {
//             print('标题: ${metadata['title']}');
//             print('艺术家: ${metadata['artist']}');
//             print('媒体ID: ${metadata['media_store_id']}');
//           }
//         }
//       }
//     });
//   }
//
//   void _listenPosition() {
//     _player.stream.position.listen((position) {
//       if (position.inMilliseconds == 0) return;
//
//       mediaManager.setPosition(position);
//
//       _settingsBox.put(
//         CacheKey.Settings.currentPosition,
//         position.inMilliseconds,
//       );
//     });
//   }
//
//   Future<void> updateQueue(List<Media> mediaList, {int? index}) async {
//     final playable = Playlist(mediaList, index: index ?? 0);
//
//     await _player.open(playable, play: false);
//   }
//
//   Future<void> play() async {
//     await _player.play();
//   }
//
//   Future<void> pause() async {
//     await _player.pause();
//   }
//
//   Future<void> seek(Duration position, {int? index}) async {
//     if (index != null) {
//       await _player.jump(index);
//     }
//
//     await _player.seek(position);
//   }
//
//   Future<void> skipToQueueItem(int index) async {
//     await _player.jump(index);
//   }
//
//   Future<void> insertQueueItem(int index, Media media) async {
//     await _player.add(media);
//   }
//
//   Future<void> skipToNext() async {
//     await _player.next();
//   }
//
//   Future<void> skipToPrevious() async {
//     await _player.previous();
//   }
//
//   void setPlayMode(PlayMode playMode) {
//     switch (playMode) {
//       case PlayMode.singleLoop:
//         setRepeatMode(PlaylistMode.single);
//         setShuffle(false);
//         break;
//       case PlayMode.random:
//         setRepeatMode(PlaylistMode.loop);
//         setShuffle(true);
//         break;
//       case PlayMode.listLoop:
//         setRepeatMode(PlaylistMode.loop);
//         setShuffle(false);
//         break;
//       case PlayMode.listOrder:
//         setRepeatMode(PlaylistMode.none);
//         setShuffle(false);
//         break;
//       default:
//         break;
//     }
//   }
//
//   Future<void> setShuffle(bool shuffle) async {
//     await _player.setShuffle(shuffle);
//   }
//
//   Future<void> setRepeatMode(PlaylistMode repeatMode) async {
//     await _player.setPlaylistMode(repeatMode);
//   }
//
//   Future<void> stop() async {
//     await _player.stop();
//   }
// }
