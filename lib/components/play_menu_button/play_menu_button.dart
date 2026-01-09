import 'package:go_router/go_router.dart';
import 'package:IceyPlayer/components/bottom_sheet/bottom_sheet.dart';
import 'package:IceyPlayer/components/round_icon_button/round_icon_button.dart';
import 'package:IceyPlayer/components/sheet_item/sheet_item.dart';
import 'package:flutter/material.dart';

class PlayMenuButton extends StatelessWidget {
  final double size;
  final Color? color;

  const PlayMenuButton({super.key, this.size = 24.0, this.color});

  void handleTap(BuildContext context) {
    final theme = Theme.of(context);

    scrollableBottomSheet(
      context: context,
      builder: (context) {
        return [
          Text("更多", style: theme.textTheme.titleMedium),
          SheetItem(
            label: "播放器样式",
            onTap: () {
              context.push("/player_style");
            },
          ),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.onSurface;

    return RoundIconButton(
      color: iconColor,
      size: size * 2,
      icon: Icon(Icons.more_vert, size: size),
      onTap: () => handleTap(context),
    );
  }
}
