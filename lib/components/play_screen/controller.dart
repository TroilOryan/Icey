import 'package:IceyPlayer/components/adaptive_builder/adaptive_builder.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/components/play_screen/concert/concert.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'landscape/landscape.dart';
import 'play_screen_background/play_screen_background.dart';
import 'portrait/portrait.dart';
import 'tablet/tablet.dart';

part 'state.dart';

part 'page.dart';

class PlayScreenController {
  final state = PlayScreenState();

  final pageController = PageController(initialPage: 1);

  void handleOpenLyric(BuildContext context) {
    if (settingsManager.immersive.value) return;

    pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void handleOpenPlaylist(BuildContext context) {
    pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onDispose() {
    pageController.dispose();
  }
}
