import 'package:IceyPlayer/components/play_lyric_shader_mask/play_lyric_shader_mask.dart';
import 'package:IceyPlayer/models/lyric/lyric.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/core/lyric_model.dart';

import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import '../../theme/theme.dart';

class PlayLyricSmall extends StatefulWidget {
  final Color? color;
  final VoidCallback? onTap;

  const PlayLyricSmall({super.key, this.color, this.onTap});

  @override
  State<PlayLyricSmall> createState() => _PlayLyricSmallState();
}

class _PlayLyricSmallState extends State<PlayLyricSmall> {
  late final EffectCleanup _listener;

  final ListController listviewController = ListController();

  final ScrollController scrollController = ScrollController();

  Widget _buildLyricItem(
    List<LyricLine> lyricList,
    int index,
    int currentIndex,
    TextStyle textStyle,
    AppThemeExtension theme,
  ) {
    final isPlaying = currentIndex == index;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
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
      // listviewController.jumpToItem(
      //     index: 0, scrollController: scrollController, alignment: 0.5);

      return;
    }

    if (length - 1 >= index) {
      listviewController.animateToItem(
        index: () => index,
        scrollController: scrollController,
        alignment: 0,
        duration: (estimatedDistance) => AppTheme.defaultDurationMid,
        curve: (estimatedDistance) => Curves.easeInOut,
      );
    }
  }

  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listener = effect(() {
        _scrollToCurrentLyric(
          lyricManager.currentIndex.value,
          lyricManager.parsedLyric.value.length,
        );
      });

      mediaManager.playbackState.map((state) => state.playing).listen((
        playing,
      ) {
        if (playing == true) {
          _scrollToCurrentLyric(
            lyricManager.currentIndex.value,
            lyricManager.parsedLyric.value.length,
          );
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    scrollController.dispose();
    listviewController.dispose();
    _listener();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final appTheme = AppThemeExtension.of(context);

    final textStyle = TextStyle(
      fontSize: theme.textTheme.titleMedium?.fontSize,
      fontWeight: FontWeight.bold,
      height: 1.5,
      color: widget.color,
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: Builder(
        builder: (context) {
          final parsedLyric = lyricManager.parsedLyric.watch(context),
              currentIndex = lyricManager.currentIndex.watch(context);

          final lineHeight = textStyle.fontSize! * textStyle.height! + 2;

          final containerHeight = lineHeight * 2.15;

          return PlayLyricShaderMask(
            colorStops: const [0.0, 0.05, 0.95, 1],
            height: containerHeight,
            child: MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: parsedLyric.isEmpty
                  ? Text("暂无歌词", style: textStyle)
                  : SuperListView.builder(
                      key: ValueKey(parsedLyric),
                      listController: listviewController,
                      controller: scrollController,
                      itemCount: parsedLyric.length,
                      itemBuilder: (context, index) => _buildLyricItem(
                        parsedLyric,
                        index,
                        currentIndex,
                        textStyle,
                        appTheme,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
