import 'package:IceyPlayer/components/play_menu_button/play_menu_button.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class ActionBar extends StatelessWidget {
  final VoidCallback onClosePanel;

  const ActionBar({super.key, required this.onClosePanel});

  @override
  Widget build(BuildContext context) {
    final appThemeExtension = AppThemeExtension.of(context);

    final immersive = settingsManager.immersive.watch(context);

    return AnimatedOpacity(
      opacity: immersive ? 0 : 1,
      duration: AppTheme.defaultDuration,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2),
        margin: EdgeInsets.only(top: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              color: appThemeExtension.primary,
              onPressed: onClosePanel,
              iconSize: 24,
              icon: Icon(Icons.keyboard_arrow_down),
            ),
            PlayMenuButton(size: 24, color: appThemeExtension.primary),
          ],
        ),
      ),
    );
  }
}
