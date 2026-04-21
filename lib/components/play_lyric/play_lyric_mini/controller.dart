import 'package:IceyPlayer/components/play_lyric_shader_mask/play_lyric_shader_mask.dart';
import 'package:IceyPlayer/models/lyric/lyric.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/core/lyric_model.dart';
import 'package:keframe/keframe.dart';

import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import '../../../theme/theme.dart';

part 'play_lyric_mini.dart';

class PlayLyricMiniController {
  late final EffectCleanup _listener;

  late final EffectCleanup _playingListener;

  final ListController listviewController = ListController();

  final ScrollController scrollController = ScrollController();

  Widget buildLyricItem(
    List<LyricLine> lyricList,
    int index,
    int currentIndex,
    TextStyle textStyle,
    AppThemeExtension theme,
  ) {
    final isPlaying = currentIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: Text(
        index < 0 ? "" : lyricList[index].text,
        style: isPlaying
            ? textStyle
            : textStyle.copyWith(color: theme.secondary),
      ),
    );
  }

  void _scrollToCurrentLyric(int? index, int? length) {
    if (index == null ||
        index < 0 ||
        length == 0 ||
        length == null ||
        !listviewController.isAttached) {
      return;
    }

    if (length - 1 >= index) {
      listviewController.animateToItem(
        index: () => index,
        scrollController: scrollController,
        alignment: 0, // 顶部对齐，确保当前歌词在第一行
        duration: (estimatedDistance) => AppTheme.defaultDurationMid,
        curve: (estimatedDistance) => Curves.easeInOut,
      );
    }
  }

  void onInit() {
    Future.delayed(const Duration(milliseconds: 300)).then((_) {
      _scrollToCurrentLyric(
        lyricManager.currentIndex.value,
        lyricManager.parsedLyric.value.length,
      );
    });

    _listener = effect(() {
      _scrollToCurrentLyric(
        lyricManager.currentIndex.value,
        lyricManager.parsedLyric.value.length,
      );
    });

    _playingListener = effect(() {
      if (mediaManager.isPlaying.value) {
        _scrollToCurrentLyric(
          lyricManager.currentIndex.value,
          lyricManager.parsedLyric.value.length,
        );
      }
    });
  }

  void onDispose() {
    scrollController.dispose();
    listviewController.dispose();
    _listener();
    _playingListener();
  }
}
