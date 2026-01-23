import 'dart:async';

import 'package:IceyPlayer/components/next_button/next_button.dart';
import 'package:IceyPlayer/components/play_button/play_button.dart';
import 'package:IceyPlayer/components/play_lyric/play_lyric.dart';
import 'package:IceyPlayer/components/prev_button/prev_button.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LyricPage extends StatefulWidget {
  final bool lyricOpened;

  const LyricPage({super.key, required this.lyricOpened});

  @override
  State<LyricPage> createState() => _LyricPageState();
}

class _LyricPageState extends State<LyricPage> {
  final controllerVisible = signal(true);

  Timer? controllerVisibleTimer;

  void handleVisibilityChanged(VisibilityInfo info) {
    final fraction = info.visibleFraction * 100;

    if (fraction == 100 && mediaManager.isPlaying) {
      controllerVisibleTimer?.cancel();

      controllerVisibleTimer = Timer(const Duration(milliseconds: 1000), () {
        controllerVisible.value = false;
      });
    } else {
      if (!controllerVisible.value) {
        controllerVisibleTimer?.cancel();

        controllerVisible.value = true;
      }
    }
  }

  void handleScroll() {
    if (!controllerVisible.value) {
      controllerVisible.value = true;

      controllerVisibleTimer?.cancel();

      controllerVisibleTimer = Timer(const Duration(milliseconds: 1000), () {
        controllerVisible.value = false;
      });
    }
  }

  void onInit() {
    mediaManager.playbackState.map((state) => state.playing).listen((playing) {
      if (playing == true) {
        controllerVisibleTimer?.cancel();

        controllerVisibleTimer = Timer(const Duration(milliseconds: 1000), () {
          controllerVisible.value = false;
        });
      } else {
        controllerVisibleTimer?.cancel();

        if (!controllerVisible.value) {
          controllerVisible.value = true;
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    onInit();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    final paddingTop = MediaQuery.of(context).padding.top;

    final paddingBottom = MediaQuery.of(context).padding.bottom;

    final appThemeExtension = AppThemeExtension.of(context);

    final _visible = controllerVisible.watch(context);

    return IgnorePointer(
      ignoring: !widget.lyricOpened,
      child: VisibilityDetector(
        key: Key("lyricPage"),
        onVisibilityChanged: handleVisibilityChanged,
        child: Offstage(
          offstage: !widget.lyricOpened,
          child: AnimatedSlide(
            curve: Curves.easeInOutSine,
            offset: Offset(0, widget.lyricOpened ? 0 : 2),
            duration: AppTheme.defaultDurationMid,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                22,
                paddingTop + deviceWidth * 0.2 + 88,
                22,
                paddingBottom + 16,
              ),
              child: Column(
                children: [
                  Flexible(child: PlayLyric(onScroll: handleScroll)),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: IgnorePointer(
                      ignoring: !_visible,
                      child: AnimatedOpacity(
                        opacity: _visible ? 1 : 0,
                        duration: AppTheme.defaultDurationMid,
                        child: Row(
                          spacing: 32,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // PlayLyricSource(),
                            PrevButton(
                              size: 24,
                              color: appThemeExtension.primary,
                            ),
                            PlayButton(
                              color: appThemeExtension.primary,
                              size: 40,
                            ),
                            NextButton(
                              size: 24,
                              color: appThemeExtension.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
