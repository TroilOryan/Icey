import 'package:IceyPlayer/components/next_button/next_button.dart';
import 'package:IceyPlayer/components/play_button/play_button.dart';
import 'package:IceyPlayer/components/play_list_button/play_list_button.dart';
import 'package:IceyPlayer/components/play_lyric/play_lyric_mini/controller.dart';
import 'package:IceyPlayer/components/play_lyric_button/play_lyric_button.dart';
import 'package:IceyPlayer/components/play_menu_button/play_menu_button.dart';
import 'package:IceyPlayer/components/play_mode_button/play_mode_button.dart';
import 'package:IceyPlayer/components/play_progress_bar/play_progress_bar.dart';
import 'package:IceyPlayer/components/play_session_button/play_session_button.dart';
import 'package:IceyPlayer/components/prev_button/prev_button.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../play_info/play_info.dart';
import '../play_shaped_cover/play_shaped_cover.dart';

class PlayPage extends StatelessWidget {
  final Function(BuildContext) onOpenLyric;

  const PlayPage({super.key, required this.onOpenLyric});

  @override
  Widget build(BuildContext context) {
    final appThemeExtension = AppThemeExtension.of(context);

    final immersive = settingsManager.immersive.watch(context);
    final coverShape = settingsManager.coverShape.watch(context);

    final deviceWidth = MediaQuery.of(context).size.width;

    final isImmersiveCover = coverShape == CoverShape.immersive;

    final showInfoHere = immersive || isImmersiveCover;

    return Column(
      children: [
        // 沉浸封面：留出封面高度（屏幕宽度）的空间
        if (isImmersiveCover)
          SizedBox(height: deviceWidth - 32)
        // 普通封面：在内部渲染
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
            child: PlayShapedCover(size: deviceWidth - 64),
          ),
        // 沉浸模式/沉浸封面时：播放信息 + 菜单按钮（移到歌词上面）
        AnimatedOpacity(
          opacity: showInfoHere ? 1 : 0,
          duration: AppTheme.defaultDuration,
          child: AnimatedContainer(
            height: showInfoHere ? null : 0,
            duration: AppTheme.defaultDuration,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 12, 0),
              child: Row(
                children: [
                  const Expanded(child: PlayInfo()),
                  const SizedBox(width: 8),
                  PlayMenuButton(size: 24, color: appThemeExtension.primary),
                ],
              ),
            ),
          ),
        ),
        if (showInfoHere) const SizedBox(height: 16),
        // 迷你歌词
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: PlayLyricMini(
            color: appThemeExtension.primary,
            onTap: () => onOpenLyric(context),
          ),
        ),
        const SizedBox(height: 24),
        // 进度条
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: StreamBuilder(
            stream: mediaManager.mediaItem,
            builder: (context, snapshot) {
              final mediaItem = snapshot.data;

              return PlayProgressBar(
                quality: mediaItem?.extras?["quality"],
                onChangeEnd: mediaManager.seek,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // 操作按钮（上一曲/播放/下一曲）
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            spacing: 32,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PrevButton(size: 24, color: appThemeExtension.primary),
              PlayButton(
                immersive: true,
                size: 40,
                color: appThemeExtension.primary,
              ),
              NextButton(size: 24, color: appThemeExtension.primary),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 功能按钮（播放模式/播放列表/会话/歌词）
        AnimatedOpacity(
          opacity: immersive ? 0 : 1,
          duration: AppTheme.defaultDuration,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PlayModeButton(size: 20, color: appThemeExtension.secondary),
                PlayListButton(size: 20, color: appThemeExtension.secondary),
                PlaySessionButton(size: 20, color: appThemeExtension.secondary),
                PlayLyricButton(
                  onTap: () => onOpenLyric(context),
                  size: 20,
                  color: appThemeExtension.secondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
