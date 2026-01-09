import 'dart:async';

import 'package:IceyPlayer/helpers/common.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:lyric/lyric_ui/ui_netease.dart';
import 'package:lyric/lyrics_model_builder.dart';
import 'package:lyric/lyrics_reader_model.dart';
import 'package:lyric/lyrics_reader_widget.dart';
import 'package:signals/signals_flutter.dart';

import '../play_lyric_shader_mask/play_lyric_shader_mask.dart';
import 'lyric_ui.dart';

class PlayLyric extends StatefulWidget {
  final VoidCallback? onScroll;

  const PlayLyric({super.key, this.onScroll});

  @override
  State<PlayLyric> createState() => _PlayLyricState();
}

class _PlayLyricState extends State<PlayLyric> {
  LyricsReaderModel? lyricModel;

  late final EffectCleanup _listener;

  late final StreamSubscription<String> rawLyricListener;

  late final StreamSubscription<bool> fakeEnhancedListener;

  void handleLineTap(int index) {
    final startTime = mediaManager.parsedLyric.value[index].startTime;

    if (startTime != null) {
      mediaManager.seek(Duration(milliseconds: startTime));
    }
  }

  void setRawLyric(String lyric, bool fakeEnhanced) {
    final res = LyricsModelBuilder.create().bindLyricToMain(lyric);

    lyricModel = res.getModel(fakeEnhanced: fakeEnhanced);
  }

  bool isHighlight(bool karaoke, bool fakeEnhanced, bool? isEnhanced) {
    if (karaoke && isEnhanced == true) {
      return true;
    } else if (!karaoke) {
      return false;
    } else if (fakeEnhanced) {
      return true;
    } else {
      return isEnhanced ?? false;
    }
  }

  Widget selectLineBuilder(int progress, Function confirm) {
    final theme = Theme.of(context);

    final appThemeExtension = AppThemeExtension.of(context);

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 0),
      decoration: BoxDecoration(
        color: appThemeExtension.primaryContainer.withAlpha(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CommonHelper.buildDuration(
            Duration(milliseconds: progress),
            appThemeExtension.primary,
            theme.textTheme.bodyLarge,
          ),
          IconButton(
            onPressed: () {
              confirm.call();
              mediaManager.seek(Duration(milliseconds: progress));
            },
            icon: SFIcon(
              SFIcons.sf_play_fill,
              color: appThemeExtension.primary,
            ),
          ),
        ],
      ),
    );
  }

  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setRawLyric(
        mediaManager.rawLyric.value,
        settingsManager.fakeEnhanced.value,
      );

      _listener = effect(() {
        setRawLyric(
          mediaManager.rawLyric.value,
          settingsManager.fakeEnhanced.value,
        );
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
    super.dispose();

    _listener();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final appThemeExtension = AppThemeExtension.of(context);

    final primary = AppThemeExtension.of(context).primary;

    final highMaterial = settingsManager.highMaterial.watch(context),
        karaoke = settingsManager.karaoke.watch(context),
        fakeEnhanced = settingsManager.fakeEnhanced.watch(context);

    final isEnhanced = lyricModel?.lyrics.any(
      (e) => e.spanList?.isNotEmpty != null && e.spanList!.isNotEmpty,
    );

    final position = computed(
      () => mediaManager.position.watch(context).inMilliseconds,
    );

    final currentMediaItem = mediaManager.currentMediaItem.value;

    final highlight = computed(
      () => isHighlight(karaoke, fakeEnhanced, isEnhanced),
    );

    return Builder(
      builder: (controller) {
        return OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;

            final textStyle = theme.textTheme.titleLarge!.copyWith(
              color: appThemeExtension.secondary,
              fontSize: isLandscape ? null : 32.sp,
            );

            final activeTextStyle = theme.textTheme.titleLarge!.copyWith(
              color: appThemeExtension.primary,
              fontSize: isLandscape ? null : 32.sp,
            );

            final extTextStyle = theme.textTheme.titleLarge!.copyWith(
              color: appThemeExtension.secondary,
              fontSize: isLandscape ? null : 20.sp,
            );

            final ui = CustomUI(
              key: ValueKey(currentMediaItem?.id),
              bias: isLandscape ? 0.8 : 0.35,
              highlight: highlight(),
              textStyle: textStyle,
              activeTextStyle: activeTextStyle,
              extTextStyle: extTextStyle,
              highlightColor: primary,
            );

            return LayoutBuilder(
              builder: (context, constraints) => PlayLyricShaderMask(
                height: constraints.maxHeight,
                child: LyricsReader(
                  position: position(),
                  model: lyricModel,
                  lyricUI: ui,
                  playing: mediaManager.isPlaying,
                  blur: highMaterial,
                  emptyBuilder: () =>
                      Center(child: Text("暂无歌词", style: activeTextStyle)),
                  // selectLineBuilder: selectLineBuilder,
                  onScroll: widget.onScroll,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
