import 'package:flutter/rendering.dart';
import 'package:signals/signals_flutter.dart';

class HomeState {
  final scanEnded = signal(false);

  final scanEndTime = signal(DateTime.now());

  final panelOpened = signal(false);

  final hidePlayBar = signal(false);

  final lastScrollOffset = signal(0.0);

  final scrollDirection = signal(ScrollDirection.idle);

  final currentIndex = signal(0);

  final sideBarOpened = signal(true);
}
