import 'dart:typed_data';

class AudioEntity {
  AudioEntity(this._info);

  final Map<dynamic, dynamic> _info;

  int get id => _info["_id"];

  String get title => _info["title"];

  String? get artist => _info["artist"];

  BigInt get artistID => BigInt.from(_info["artist_id"] ?? 0);

  String? get album => _info["album"];

  BigInt get albumID => BigInt.from(_info["album_id"] ?? 0);

  int? get track => _info["track"];

  int? get year => _info["year"];

  // ms
  int? get duration => _info["duration"];

  String get data => _info["_data"];

  String get uri => _info["_uri"];

  // s
  int? get dateAdded => _info["date_added"];

  // s
  int? get dateModified => _info["date_modified"];

  int? get bitRate => _info["bitRate"];

  int? get sampleRate => _info["sampleRate"];

  int? get bitDepth => _info["bitDepth"];

  String get quality => _info["quality"];

  /// Return a map with all [keys] and [values] from specific song.
  Map get getMap => _info;

  @override
  String toString() {
    return _info.toString();
  }
}

class ArtworkColorEntity {
  final int? primaryColor;
  final int? secondaryColor;
  final bool? isDark;

  const ArtworkColorEntity({
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });
}
