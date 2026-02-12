import 'dart:typed_data';

import 'package:hive_ce/hive.dart';

const _typeId = 3;

@HiveType(typeId: _typeId, adapterName: "MediaOrderEntityAdapter")
class MediaOrderEntity {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> mediaIDs;

  /// 自定义封面
  @HiveField(3)
  final Uint8List? cover;

  const MediaOrderEntity({
    required this.id,
    required this.name,
    required this.mediaIDs,
    this.cover,
  });

  MediaOrderEntity copyWith({
    String? id,
    String? name,
    List<String>? mediaIDs,
    Uint8List? cover,
  }) {
    return MediaOrderEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      mediaIDs: mediaIDs ?? this.mediaIDs,
      cover: cover,
    );
  }
}

class MediaOrderEntityAdapter extends TypeAdapter<MediaOrderEntity> {
  @override
  final int typeId = _typeId;

  @override
  MediaOrderEntity read(BinaryReader reader) {
    return MediaOrderEntity(
      id: reader.read(),
      name: reader.read(),
      mediaIDs: reader.read(),
      cover: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaOrderEntity obj) {
    writer
      ..write(obj.id)
      ..write(obj.name)
      ..write(obj.mediaIDs)
      ..write(obj.cover);
  }
}
