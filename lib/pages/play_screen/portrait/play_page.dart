import 'package:IceyPlayer/components/next_button/next_button.dart';
import 'package:IceyPlayer/components/play_button/play_button.dart';
import 'package:IceyPlayer/components/play_list_button/play_list_button.dart';
import 'package:IceyPlayer/components/play_lyric/play_lyric_small.dart';
import 'package:IceyPlayer/components/play_lyric_button/play_lyric_button.dart';
import 'package:IceyPlayer/components/play_mode_button/play_mode_button.dart';
import 'package:IceyPlayer/components/play_progress_bar/play_progress_bar.dart';
import 'package:IceyPlayer/components/play_session_button/play_session_button.dart';
import 'package:IceyPlayer/components/prev_button/prev_button.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

final _likedBox = Boxes.likedBox;

class PlayPage extends StatelessWidget {
  final bool panelOpened;
  final bool lyricOpened;
  final Function(BuildContext) onOpenLyric;

  const PlayPage({
    super.key,
    required this.panelOpened,
    required this.lyricOpened,
    required this.onOpenLyric,
  });

  Future<bool> handleLike(String? id, bool liked) async {
    if (id == null) {
      return liked;
    }

    _likedBox.put(int.parse(id), !liked);

    return !liked;
  }

  @override
  Widget build(BuildContext context) {
    final appThemeExtension = AppThemeExtension.of(context);

    final immersive = settingsManager.immersive.watch(context);

    return IgnorePointer(
      ignoring: lyricOpened,
      child: AnimatedOpacity(
        opacity: lyricOpened ? 0 : 1,
        duration: AppTheme.defaultDurationMid,
        child: AnimatedSlide(
          curve: Curves.easeInOutSine,
          offset: Offset(0, lyricOpened ? 2 : 0),
          duration: AppTheme.defaultDurationMid,
          child: Column(
            children: [
              AnimatedOpacity(
                opacity: immersive ? 0 : 1,
                duration: AppTheme.defaultDuration,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    32,
                    MediaQuery.of(context).size.width * 1.2 + 46,
                    32,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24),
                      PlayLyricSmall(
                        color: appThemeExtension.primary,
                        onTap: () => onOpenLyric(context),
                      ),
                      SizedBox(height: 24),
                      StreamBuilder(
                        stream: mediaManager.mediaItem,
                        builder: (context, snapshot) {
                          final mediaItem = snapshot.data;

                          return PlayProgressBar(
                            quality: mediaItem?.extras?["quality"],
                            onChangeEnd: mediaManager.seek,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Flexible(
                child: AnimatedSlide(
                  curve: Curves.easeInOutSine,
                  offset: Offset(0, immersive ? -0.5 : 0),
                  duration: AppTheme.defaultDurationMid,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          spacing: 32,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PrevButton(
                              size: 24,
                              color: appThemeExtension.primary,
                            ),
                            PlayButton(
                              immersive: true,
                              size: 40,
                              color: appThemeExtension.primary,
                            ),
                            NextButton(
                              size: 24,
                              color: appThemeExtension.primary,
                            ),
                          ],
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: immersive ? 0 : 1,
                        duration: AppTheme.defaultDuration,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Row(
                            spacing: 16,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PlayModeButton(
                                size: 20,
                                color: appThemeExtension.secondary,
                              ),
                              PlayListButton(
                                size: 20,
                                color: appThemeExtension.secondary,
                              ),
                              PlaySessionButton(
                                size: 20,
                                color: appThemeExtension.secondary,
                              ),
                              PlayLyricButton(
                                active: lyricOpened,
                                onTap: () => onOpenLyric(context),
                                size: 20,
                                color: appThemeExtension.secondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
