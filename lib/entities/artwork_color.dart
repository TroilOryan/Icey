import 'package:hive_ce/hive.dart';

const _typeId = 2;

@HiveType(typeId: _typeId, adapterName: "ArtworkColorAdapter")
class ArtworkColorEntity {
  @HiveField(0)
  final int primary;

  @HiveField(1)
  final int secondary;

  @HiveField(2)
  final bool isDark;

  ArtworkColorEntity({
    required this.primary,
    required this.secondary,
    required this.isDark,
  });
}

class ArtworkColorEntityAdapter extends TypeAdapter<ArtworkColorEntity> {
  @override
  final int typeId = _typeId;

  @override
  ArtworkColorEntity read(BinaryReader reader) => ArtworkColorEntity(
        primary: reader.read(),
        secondary: reader.read(),
        isDark: reader.read(),
      );

  @override
  void write(BinaryWriter writer, ArtworkColorEntity obj) {
    writer
      ..write(obj.primary)
      ..write(obj.secondary)
      ..write(obj.isDark);
  }
}
