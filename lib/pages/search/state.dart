import 'package:IceyPlayer/entities/media.dart';
import 'package:signals/signals_flutter.dart';

class SearchState {
  final keyword = signal("");

  final mediaList = signal<List<MediaEntity>>([]);
}
