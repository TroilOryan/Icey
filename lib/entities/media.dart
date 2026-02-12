import 'package:audio_query/entities.dart';
import 'package:audio_service/audio_service.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

const _typeId = 1;

const _uuid = Uuid();

@HiveType(typeId: _typeId, adapterName: "MediaEntityAdapter")
class MediaEntity {
  @HiveField(0)
  final bool favorite;

  @HiveField(1)
  final String id;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String? artist;

  @HiveField(4)
  final String? artistID;

  @HiveField(5)
  final String? album;

  @HiveField(6)
  final String? albumID;

  @HiveField(7)
  final int? track;

  @HiveField(8)
  final int? year;

  @HiveField(9)
  final int? duration;

  @HiveField(10)
  final String data;

  @HiveField(11)
  final String uri;

  @HiveField(12)
  final int? dateAdded;

  @HiveField(13)
  final int? dateModified;

  @HiveField(14)
  final int? bitRate;

  @HiveField(15)
  final int? sampleRate;

  @HiveField(16)
  final int? bitDepth;

  @HiveField(17)
  final String quality;

  @HiveField(18)
  final String? artUri;

  MediaEntity({
    required this.favorite,
    required this.id,
    required this.title,
    required this.artist,
    required this.artistID,
    required this.album,
    required this.albumID,
    required this.track,
    required this.year,
    required this.duration,
    required this.data,
    required this.uri,
    required this.dateAdded,
    required this.dateModified,
    required this.bitRate,
    required this.sampleRate,
    required this.bitDepth,
    required this.quality,
    required this.artUri,
  });

  MediaEntity copyWith({
    bool? favorite,
    String? id,
    String? title,
    String? artist,
    String? artistID,
    String? album,
    String? albumID,
    int? track,
    int? year,
    int? duration,
    String? data,
    String? uri,
    int? dateAdded,
    int? dateModified,
    int? bitRate,
    int? sampleRate,
    int? bitDepth,
    String? quality,
    String? artUri,
  }) {
    return MediaEntity(
      favorite: favorite ?? this.favorite,
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistID: artistID ?? this.artistID,
      album: album ?? this.album,
      albumID: albumID ?? this.albumID,
      track: track ?? this.track,
      year: year ?? this.year,
      duration: duration ?? this.duration,
      data: data ?? this.data,
      uri: uri ?? this.uri,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      bitRate: bitRate ?? this.bitRate,
      sampleRate: sampleRate ?? this.sampleRate,
      bitDepth: bitDepth ?? this.bitDepth,
      quality: quality ?? this.quality,
      artUri: artUri ?? this.artUri,
    );
  }

  static MediaEntity fromMediaStore(AudioEntity audio) {
    return MediaEntity(
      id: audio.id,
      favorite: false,
      title: audio.title,
      artist: audio.artist,
      artistID: audio.artistID,
      album: audio.album,
      albumID: audio.albumID,
      track: audio.track,
      year: audio.year,
      duration: audio.duration,
      data: audio.data,
      uri: audio.uri,
      dateAdded: audio.dateAdded,
      dateModified: audio.dateModified,
      bitRate: audio.bitRate,
      sampleRate: audio.sampleRate,
      bitDepth: audio.bitDepth,
      quality: audio.quality,
      artUri: '${audio.uri}/albumart',
    );
  }

  static MediaItem toMediaItem(MediaEntity media) => MediaItem(
          id: media.id.toString(),
          album: media.album ?? '',
          title: media.title,
          artist: media.artist,
          duration: Duration(milliseconds: media.duration ?? 0),
          artUri: media.artUri != null ? Uri.parse(media.artUri!) : null,
          extras: {
            "uuid": _uuid.v4(),
            "quality": media.quality,
            'path': media.data,
            "uri": media.uri
          });
}

class MediaEntityAdapter extends TypeAdapter<MediaEntity> {
  @override
  final int typeId = _typeId;

  @override
  MediaEntity read(BinaryReader reader) {
    return MediaEntity(
      favorite: reader.read(),
      id: reader.read(),
      title: reader.read(),
      artist: reader.read(),
      artistID: reader.read(),
      album: reader.read(),
      albumID: reader.read(),
      track: reader.read(),
      year: reader.read(),
      duration: reader.read(),
      data: reader.read(),
      uri: reader.read(),
      dateAdded: reader.read(),
      dateModified: reader.read(),
      bitRate: reader.read(),
      sampleRate: reader.read(),
      bitDepth: reader.read(),
      quality: reader.read(),
      artUri: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaEntity obj) {
    writer
      ..write(obj.favorite)
      ..write(obj.id)
      ..write(obj.title)
      ..write(obj.artist)
      ..write(obj.artistID)
      ..write(obj.album)
      ..write(obj.albumID)
      ..write(obj.track)
      ..write(obj.year)
      ..write(obj.duration)
      ..write(obj.data)
      ..write(obj.uri)
      ..write(obj.dateAdded)
      ..write(obj.dateModified)
      ..write(obj.bitRate)
      ..write(obj.sampleRate)
      ..write(obj.bitDepth)
      ..write(obj.quality)
      ..write(obj.artUri);
  }
}
