import 'dart:typed_data';

import 'package:IceyPlayer/entities/artist.dart';
import 'package:signals/signals_flutter.dart';

class CoverMap {
  final BigInt id;

  final Uint8List cover;

  const CoverMap({required this.id, required this.cover});
}

class ArtistListState {
  final coverList = signal<List<CoverMap>>([]);
}
