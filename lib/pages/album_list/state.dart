import 'dart:typed_data';

import 'package:IceyPlayer/entities/album.dart';
import 'package:signals/signals_flutter.dart';

class CoverMap {
  final BigInt id;

  final Uint8List cover;

  const CoverMap({required this.id, required this.cover});
}

class AlbumListState {
  final coverList = signal<List<CoverMap>>([]);
}
