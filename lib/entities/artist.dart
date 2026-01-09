class ArtistEntity {
  final BigInt id;
  final String name;
  final List<int> mediaIDs;

  ArtistEntity copyWith({BigInt? id, String? name, List<int>? mediaIDs}) {
    return ArtistEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      mediaIDs: mediaIDs ?? this.mediaIDs,
    );
  }

  ArtistEntity({required this.id, required this.name, required this.mediaIDs});
}
