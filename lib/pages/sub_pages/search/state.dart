part of 'controller.dart';

class SearchState {
  final keyword = signal("");

  final mediaList = signal<List<MediaEntity>>([]);
}
