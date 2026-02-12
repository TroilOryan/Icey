class AudioEntity {
  AudioEntity(this._info);

  final Map<dynamic, dynamic> _info;

  String get id =>
      _info["_id"] != null ? _info["_id"].toString() : _info["path"];

  String get title => _info["title"];

  String? get artist => _info["artist"];

  String get artistID => (_info["artist_id"] ?? 0).toString();

  String? get album => _info["album"];

  String get albumID => (_info["album_id"] ?? 0).toString();

  int? get track => _info["track"];

  int? get year => _info["year"];

  // ms
  int? get duration => _info["duration"];

  String get data => _info["_data"] ?? _info["path"];

  String get uri => _info["_uri"] ?? _info["path"];

  // s
  int? get dateAdded => _info["date_added"] ?? _info["created"];

  // s
  int? get dateModified => _info["date_modified"] ?? _info["modified"];

  int? get bitRate => _info["bitRate"];

  int? get sampleRate => _info["sampleRate"] ?? _info["sample_rate"];

  int? get bitDepth => _info["bitDepth"] ?? _info["bit_depth"];

  String get quality => _info["quality"];

  String? get by => _info["by"];

  int? get channels => _info["channels"];

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
