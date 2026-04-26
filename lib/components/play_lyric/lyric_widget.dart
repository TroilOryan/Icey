import 'package:IceyPlayer/components/play_lyric/play_lyric_style.dart';
import 'package:IceyPlayer/models/lyric/lyric.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart' hide LyricVi;
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
      fontSize: isLandscape ? 20 : 32,
    );

    final activeTextStyle = theme.textTheme.titleLarge!.copyWith(
      color: appThemeExtension.primary,
      fontSize: isLandscape ? 20 : 32,
    );

    final extTextStyle = theme.textTheme.titleLarge!.copyWith(
      color: appThemeExtension.secondary,
      fontSize: isLandscape ? 18 : 20,
    );

    final baseStyle = PlayLyricStyle.default1.copyWith(
      textStyle: textStyle,
      activeStyle: activeTextStyle,
      translationStyle: extTextStyle,
      activeHighlightGradient: LinearGradient(
        colors: [
          theme.colorScheme.inversePrimary,
          theme.colorScheme.primaryContainer,
        ],
      ),
      selectLineResumeMode: .selecting,
      activeHighlightColor: isHighlight
          ? theme.colorScheme.inversePrimary
          : null,
    );

    // 横屏时当前歌词居中（activeAnchorPosition: 0.5 = 视口高度的 50%）
    final lyricStyle = isLandscape
        ? PlayLyricStyle.landscape(baseStyle)
        : baseStyle;

    if (parsedLyric.isEmpty) {
      return Center(child: Text('暂无歌词', style: extTextStyle));
    }

    return Stack(
      children: [
        LyricSelectionContentBackground(
          controller: controller,
          style: lyricStyle,
          color: theme.cardTheme.color!.withAlpha(100),
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
