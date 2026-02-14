import 'package:IceyPlayer/components/round_icon_button/round_icon_button.dart';
import 'package:IceyPlayer/helpers/throttle.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';

final Throttle _throttle = Throttle(const Duration(seconds: 1));

/// 上一首
class PrevButton extends StatelessWidget {
  final double size;
  final Color? color;
  final bool ghost;

  const PrevButton({
    super.key,
    this.size = 24.0,
    this.color,
    this.ghost = true,
  });

  void skipToPrevious() {
    _throttle.call(mediaManager.skipToPrevious);
  }

  void rewind() {
    _throttle.call(mediaManager.rewind);
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.onSurface;

    return RoundIconButton(
      color: iconColor,
      size: size * 2.5,
      ghost: ghost,
      icon: SFIcon(SFIcons.sf_backward_fill, fontSize: size),
      onTap: skipToPrevious,
      onLongPress: rewind,
    );
  }
}
