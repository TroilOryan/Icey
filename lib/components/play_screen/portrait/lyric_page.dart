import 'dart:async';

import 'package:IceyPlayer/components/next_button/next_button.dart';
import 'package:IceyPlayer/components/play_button/play_button.dart';
import 'package:IceyPlayer/components/play_lyric/play_lyric.dart';
import 'package:IceyPlayer/components/prev_button/prev_button.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class LyricPage extends StatefulWidget {
  const LyricPage({super.key});

  @override
  State<LyricPage> createState() => _LyricPageState();
}

class _LyricPageState extends State<LyricPage> {
  Timer? controllerVisibleTimer;

  final controllerVisible = signal(true);

  void handleScroll() {
    if (!controllerVisible.value) {
      controllerVisible.value = true;

      controllerVisibleTimer?.cancel();

      controllerVisibleTimer = Timer(const Duration(milliseconds: 3000), () {
        controllerVisible.value = false;
      });
    }
  }

  void onInit() {
    effect(() {
      if (mediaManager.isPlaying.value == true) {
        controllerVisibleTimer?.cancel();

        controllerVisibleTimer = Timer(const Duration(milliseconds: 3000), () {
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
    super.initState();

    onInit();
  }

  @override
  Widget build(BuildContext context) {
    final paddingBottom = MediaQuery.of(context).viewInsets.bottom;

    final appThemeExtension = AppThemeExtension.of(context);

    final visible = controllerVisible.watch(context);

    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          22,
          16,
          22,
          paddingBottom + 32,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: PlayLyric(onScroll: handleScroll),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: AppTheme.defaultDurationMid,
                child: Row(
                  spacing: 32,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
          ],
        ),
      ),
    );
  }
}
