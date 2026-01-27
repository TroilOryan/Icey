import 'package:IceyPlayer/models/lyric/lyric.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:signals/signals_flutter.dart';

class LyricWidget extends StatelessWidget {
  final LyricController controller;
  final bool isLandscape;
  final bool isHighlight;

  const LyricWidget({
    super.key,
    required this.controller,
    required this.isLandscape,
    required this.isHighlight,
  });

  @override
  Widget build(BuildContext context) {
    final parsedLyric = lyricManager.parsedLyric.watch(context);

    final theme = Theme.of(context);

    final appThemeExtension = AppThemeExtension.of(context);

    final textStyle = theme.textTheme.titleLarge!.copyWith(
      color: appThemeExtension.secondary,
      fontSize: isLandscape ? null : 32,
      fontWeight: FontWeight.bold,
    );

    final activeTextStyle = theme.textTheme.titleLarge!.copyWith(
      color: appThemeExtension.primary,
      fontSize: isLandscape ? null : 32,
      fontWeight: FontWeight.bold,
    );

    final extTextStyle = theme.textTheme.titleLarge!.copyWith(
      color: appThemeExtension.secondary,
      fontSize: isLandscape ? null : 20,
    );

    final lyricStyle = LyricStyles.default1.copyWith(
      textAlign: .left,
      contentAlignment: .start,
      contentPadding: EdgeInsets.only(top: 200),
      textStyle: textStyle,
      activeStyle: activeTextStyle,
      translationStyle: extTextStyle,
      // selectedColor: theme.colorScheme.primary,
      activeHighlightGradient: isHighlight
          ? LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.inversePrimary,
              ],
            )
          : null,
      selectLineResumeMode: SelectionAutoResumeMode.selecting,
      activeHighlightColor: isHighlight
          ? theme.colorScheme.inversePrimary
          : null,
      scrollCurve: Curves.easeInOutSine,
      scrollDuration: const Duration(milliseconds: 600),
    );

    if (parsedLyric.isEmpty) {
      return Center(child: Text('暂无歌词', style: extTextStyle));
    }

    return Stack(
      children: [
        LyricSelectionContentBackground(
          controller: controller,
          style: lyricStyle,
        ),
        LyricView(controller: controller, style: lyricStyle),
        LyricSelectionProgress(
          controller: controller,
          onPlay: (SelectionState state) async {
            // lyricController.stopSelection();
            // await player.seek(state.duration);
            // player.play();
          },
          style: lyricStyle,
        ),
      ],
    );
  }
}
