import 'package:IceyPlayer/components/marquee/marquee.dart';
import 'package:IceyPlayer/models/lyric/lyric.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../theme/theme.dart';

class PlayBarLyric extends StatelessWidget {
  const PlayBarLyric({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentIndex = lyricManager.currentIndex.watch(context),
        parsedLyric = lyricManager.parsedLyric.watch(context);

    return AnimatedSwitcher(
      switchInCurve: Curves.easeInSine,
      switchOutCurve: Curves.easeOutSine,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 2),
                end: const Offset(0, 0),
              ).animate(animation),
              child: child,
            ),
          ),
      duration: AppTheme.defaultDuration,
      child: Align(
        key: currentIndex != -1 ? ValueKey(currentIndex) : null,
        alignment: Alignment.centerLeft,
        child: Marquee(
          child: Text(
            currentIndex != -1 && parsedLyric.isNotEmpty
                ? parsedLyric[currentIndex].text
                : "暂无歌词",
            style: theme.textTheme.bodyMedium?.copyWith(
              leadingDistribution: TextLeadingDistribution.even,
              decoration: TextDecoration.none,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: true,
          ),
        ),
      ),
    );
  }
}
