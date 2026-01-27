import 'package:IceyPlayer/components/marquee/marquee.dart';
import 'package:IceyPlayer/components/next_button/next_button.dart';
import 'package:IceyPlayer/components/play_button/play_button.dart';
import 'package:IceyPlayer/components/play_progress_button/play_progress_button.dart';
import 'package:IceyPlayer/components/prev_button/prev_button.dart';
import 'package:IceyPlayer/models/lyric/lyric.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:signals_flutter/signals_flutter.dart';

// 演唱会模式
class Concert extends StatefulWidget {
  const Concert({super.key});

  @override
  State<Concert> createState() => _ConcertState();
}

class _ConcertState extends State<Concert> {
  final lyricController = LyricController();

  final isHighlight = signal(false);

  late final EffectCleanup lyricListener;

  late final EffectCleanup progressListener;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    lyricListener = effect(() {
      if (lyricManager.lyricModel.value != null) {
        isHighlight.value = lyricManager.lyricModel.value!.lines.any(
          (e) => e.words != null && e.words!.isNotEmpty,
        );

        lyricController
          ..loadLyric(lyricManager.rawLyric.value)
          ..loadLyricModel(lyricManager.lyricModel.value!);
      }
    });

    progressListener = effect(() {
      lyricController.setProgress(mediaManager.position.value);
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setPreferredOrientations([]);

    lyricListener();

    progressListener();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentIndex = lyricManager.currentIndex.watch(context),
        parsedLyric = lyricManager.parsedLyric.watch(context);

    final hasNext = computed(
      () => currentIndex != -1 && currentIndex < parsedLyric.length - 1,
    );

    final nextLyric = computed(
      () => hasNext.value ? parsedLyric[currentIndex + 1] : null,
    );

    final textStyle = theme.textTheme.titleLarge!.copyWith(
      color: Colors.white,
      fontSize: 66,
    );

    final activeTextStyle = theme.textTheme.titleLarge!.copyWith(
      color: Colors.white,
      fontSize: 66,
    );

    final extTextStyle = theme.textTheme.titleLarge!.copyWith(
      color: Colors.white,
      fontSize: 32,
    );

    final lyricStyle = LyricStyles.single.copyWith(
      textAlign: .center,
      contentAlignment: .center,
      contentPadding: EdgeInsets.only(top: 200),
      textStyle: textStyle,
      activeStyle: activeTextStyle,
      translationStyle: extTextStyle,
      scrollCurve: Curves.easeInOutSine,
      scrollDuration: const Duration(milliseconds: 0),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (parsedLyric.isNotEmpty)
              Positioned.fill(
                child: LyricView(
                  controller: lyricController,
                  style: lyricStyle,
                ),
              )
            else
              Positioned.fill(
                child: Center(child: Text('暂无歌词', style: extTextStyle)),
              ),
            Positioned(
              right: 24,
              bottom: 24,
              child: Row(
                mainAxisAlignment: .center,
                children: [
                  PrevButton(ghost: true, size: 20, color: Colors.white54),
                  PlayProgressButton(size: 22, color: Colors.white),
                  NextButton(ghost: true, size: 20, color: Colors.white54),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
