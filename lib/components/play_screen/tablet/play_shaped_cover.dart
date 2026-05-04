import 'dart:async';

import 'package:IceyPlayer/components/play_cover/play_cover.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

/// 圆形、方形、不规则（平板端）
class PlayShapedCover extends StatefulWidget {
  final double size;

  const PlayShapedCover({super.key, required this.size});

  @override
  State<PlayShapedCover> createState() => _PlayShapedCoverState();
}

class _PlayShapedCoverState extends State<PlayShapedCover>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  StreamSubscription<PlaybackState>? _playbackSub;
  StreamSubscription<MediaItem?>? _mediaItemSub;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      reverseDuration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _playbackSub = mediaManager.playbackState.listen((state) {
      if (state.playing && !_rotationController.isAnimating) {
        _rotationController.repeat();
      } else if (!state.playing && _rotationController.isAnimating) {
        _rotationController.stop();
      }
    });

    _mediaItemSub = mediaManager.mediaItem.listen((_) {
      _rotationController.reverse();
    });

    if (mediaManager.playbackState.value.playing) {
      _rotationController.repeat();
    }
  }

  @override
  void dispose() {
    _playbackSub?.cancel();
    _mediaItemSub?.cancel();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final diskShadowColor = theme.colorScheme.secondaryContainer;

    final coverShape = settingsManager.coverShape.watch(context);

    if (coverShape == CoverShape.circle) {
      return RotationTransition(
        turns: _rotationController,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: diskShadowColor.withAlpha(13),
                    spreadRadius: 13,
                    blurRadius: 33,
                  ),
                ],
                border: Border.all(
                  width: 1,
                  color: diskShadowColor.withAlpha(22),
                ),
                shape: BoxShape.circle,
                color: diskShadowColor.withAlpha(22),
              ),
            ),
            Positioned(
              left: 24,
              top: 24,
              child: Container(
                width: widget.size - 48,
                height: widget.size - 48,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.asset(
                  'assets/images/music_back.png',
                  gaplessPlayback: true,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned(
              left: widget.size / 2 - widget.size / 4,
              top: widget.size / 2 - widget.size / 4,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: PlayCover(
                  noCover: true,
                  duration: AppTheme.defaultDurationLong,
                  width: widget.size / 2,
                  height: widget.size / 2,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (coverShape == CoverShape.rectangle) {
      return Container(
        key: ValueKey(widget.size),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: diskShadowColor.withAlpha(13),
              spreadRadius: 13,
              blurRadius: 33,
            ),
          ],
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
        ),
        child: PlayCover(
          duration: AppTheme.defaultDurationLong,
          width: widget.size - 8,
          height: widget.size - 8,
        ),
      );
    } else if (coverShape == CoverShape.irregular) {
      return PlayCover(
        duration: AppTheme.defaultDurationLong,
        width: widget.size - 8,
        height: widget.size - 8,
      );
    }

    return const SizedBox();
  }
}
