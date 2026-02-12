class AlbumEntity {
  final String id;
  final String name;
  final List<String> mediaIDs;

  AlbumEntity copyWith({String? id, String? name, List<String>? mediaIDs}) {
    return AlbumEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      mediaIDs: mediaIDs ?? this.mediaIDs,
    );
  }

  AlbumEntity({required this.id, required this.name, required this.mediaIDs});
}
