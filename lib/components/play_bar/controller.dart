import 'dart:math';

import 'package:IceyPlayer/components/adaptive_builder/adaptive_builder.dart';
import 'package:IceyPlayer/components/next_button/next_button.dart';
import 'package:IceyPlayer/components/play_button/play_button.dart';
import 'package:IceyPlayer/components/play_list_button/play_list_button.dart';
import 'package:IceyPlayer/components/play_mode_button/play_mode_button.dart';
import 'package:IceyPlayer/components/prev_button/prev_button.dart';
import 'package:IceyPlayer/constants/glass_settings.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:signals/signals_flutter.dart';

import 'package:flutter/services.dart';
import 'package:IceyPlayer/components/play_cover/play_cover.dart';
import 'package:IceyPlayer/components/play_progress_button/play_progress_button.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';
import 'package:keframe/keframe.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../theme/theme.dart';
import 'play_info.dart';

part 'state.dart';

part 'mobile/play_bar_mobile.dart';

part 'desktop/play_bar_desktop.dart';

class PlayBarController {
  final double playBarHeight = 64;

  final state = PlayBarState();

  void handleHorizontalDragUpdate(DragUpdateDetails details) {
    state.delta.value += details.delta.dx;

    state.isNext.value = state.delta.value > 0 ? -1 : 1;
  }

  void handleHorizontalDragEnd(DragEndDetails details) {
    if (state.delta.value.abs() >= 55) {
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

    if (fraction == 100 && state.delta.abs() >= 55) {
      HapticFeedback.lightImpact();
    }
  }
}
