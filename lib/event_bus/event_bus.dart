import "dart:typed_data";

import "package:audio_query/entities.dart";
import "package:event_bus/event_bus.dart";

// 创建事件总线实例
final EventBus eventBus = EventBus();

class ScanMediaStatus {
  final bool isStart;
  final bool? silent;

  ScanMediaStatus(this.isStart, [this.silent]);
}

class OpenSortMenu {}

/// 扫描媒体+1
class ScanMediaAdd {
  final List<AudioEntity> audios;

  ScanMediaAdd(this.audios);
}

/// 我喜欢变更
class LikeMediaChange {
  final String id;
  final bool liked;

  LikeMediaChange(this.id, this.liked);
}

/// 歌单变更
/// 可能是创建和删除
class MediaOrderChange {
  final String id;
  final String name;
  final bool isDelete;
  final List<String>? mediaIDs;
  final Uint8List? cover;

  MediaOrderChange({
    required this.id,
    required this.name,
    this.isDelete = false,
    this.mediaIDs,
    this.cover,
  });
}

/// 歌单封面修改
/// 可能是更换和清空
/// cover是更换 randomCover是清空并换成随机封面
class MediaOrderCoverChange {
  final String id;
  final Uint8List? cover;
  final Uint8List? randomCover;

  MediaOrderCoverChange({
    required this.id,
    required this.cover,
    this.randomCover,
  });
}
