part of 'play_bar.dart';

class PlayBarController {
  final state = PlayBarState();

  void handleHorizontalDragUpdate(DragUpdateDetails details) {
    state.delta.value += details.delta.dx;

    state.isNext.value = state.delta.value > 0 ? -1 : 1;
  }

  void handleHorizontalDragEnd(DragEndDetails details) {
    if (state.delta.value.abs() >= 66) {
      final isNext = state.isNext.value;

      Future.delayed(const Duration(milliseconds: 100)).then((_) {
        if (isNext == 1) {
          mediaManager.skipToNext();
        } else if (isNext == -1) {
          mediaManager.skipToPrevious();
        }
      });
    }

    state.delta.value = 0;
    state.isNext.value = 0;
  }

  void handleVisibilityChanged(VisibilityInfo info) {
    final fraction = info.visibleFraction * 100;

    if (fraction == 100 && state.delta.abs() >= 66) {
      HapticFeedback.lightImpact();
    }
  }
}
