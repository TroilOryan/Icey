part of 'controller.dart';

class CoverMap {
  final String id;

  final Uint8List cover;

  const CoverMap({required this.id, required this.cover});
}

class ArtistListState {
  final coverList = signal<List<CoverMap>>([]);
}
