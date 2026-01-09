class AlbumEntity {
  final BigInt id;
  final String name;
  final List<int> mediaIDs;

  AlbumEntity copyWith({BigInt? id, String? name, List<int>? mediaIDs}) {
    return AlbumEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      mediaIDs: mediaIDs ?? this.mediaIDs,
    );
  }

  AlbumEntity({required this.id, required this.name, required this.mediaIDs});
}
