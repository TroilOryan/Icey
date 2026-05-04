import 'package:IceyPlayer/components/adaptive_builder/adaptive_builder.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'concert/concert.dart';
import 'landscape/landscape.dart';
import 'play_screen_background/play_screen_background.dart';
import 'portrait/portrait.dart';
import 'tablet/tablet.dart';

part 'state.dart';

part 'page.dart';

class PlayScreenController {
  final state = PlayScreenState();

  /// PlayScreen 构建时设置，dispose 时清空
  PageController? pageController;

  void handleOpenLyric(PageController controller, BuildContext context) {
    if (settingsManager.immersive.value) return;

    controller.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void handleOpenPlaylist(PageController controller, BuildContext context) {
    controller.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
