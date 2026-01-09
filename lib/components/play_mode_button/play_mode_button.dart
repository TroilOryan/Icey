import 'package:IceyPlayer/components/round_icon_button/round_icon_button.dart';
import 'package:IceyPlayer/helpers/toast/toast.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:signals/signals_flutter.dart';

/// 播放模式
class PlayModeButton extends StatelessWidget {
  final double size;
  final Color? color;

  const PlayModeButton({super.key, this.size = 24.0, this.color});

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.onSurface;

    final playMode = mediaManager.playMode.watch(context);

    return RoundIconButton(
      size: size * 2.1,
      color: iconColor,
      icon: SFIcon(playMode.icon, fontSize: size),
      onTap: mediaManager.togglePlayerMode,
    );
  }
}
