import 'dart:ui';

import 'package:IceyPlayer/components/bottom_sheet/bottom_sheet.dart';
import 'package:IceyPlayer/components/play_list_button/play_list.dart';
import 'package:IceyPlayer/components/round_icon_button/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';

class PlayListButton extends StatelessWidget {
  final double size;
  final Color? color;

  const PlayListButton({
    super.key,
    this.size = 24,
    this.color,
  });

  void handleTap(BuildContext context) {
    bottomSheet(
      context: context,
      builder: (context, controller) {
        return PlayList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.onSurface;

    return RoundIconButton(
      size: size * 2.1,
      icon: SFIcon(SFIcons.sf_list_bullet, fontSize: size),
      color: iconColor,
      onTap: () => handleTap(context),
    );
  }
}
