import 'package:just_audio/just_audio.dart';

class CustomShuffleOrder extends DefaultShuffleOrder {
  @override
  void insert(int index, int count) {
    for (int i = 0; i < indices.length; i++) {
      if (indices[i] >= index) {
        indices[i] += count;
      }
    }

    final newIndices = List.generate(count, (i) => index + i);

    indices.insertAll(index, newIndices);
  }
}
