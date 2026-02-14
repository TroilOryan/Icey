import 'package:IceyPlayer/components/round_icon_button/round_icon_button.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';

import '../../helpers/throttle.dart';

final Throttle _throttle = Throttle(const Duration(seconds: 1));

/// 下一首
class NextButton extends StatelessWidget {
  final double size;
  final Color? color;
  final bool ghost;

  void skipToNext() {
    _throttle.call(mediaManager.skipToNext);
  }

  void fastForward() {
    _throttle.call(mediaManager.fastForward);
  }

  const NextButton({
    super.key,
    this.ghost = true,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.onSurface;

    return RoundIconButton(
      size: size * 2.5,
      color: iconColor,
      ghost: ghost,
      icon: SFIcon(SFIcons.sf_forward_fill, fontSize: size),
      onTap: skipToNext,
      onLongPress: fastForward,
    );
  }
}
