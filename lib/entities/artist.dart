class ArtistEntity {
  final String id;
  final String name;
  final List<String> mediaIDs;

  ArtistEntity copyWith({String? id, String? name, List<String>? mediaIDs}) {
    return ArtistEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      mediaIDs: mediaIDs ?? this.mediaIDs,
    );
  }

  ArtistEntity({required this.id, required this.name, required this.mediaIDs});
}
