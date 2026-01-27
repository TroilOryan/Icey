import 'package:IceyPlayer/components/marquee/marquee.dart';
import 'package:IceyPlayer/models/lyric/lyric.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals_flutter/signals_flutter.dart';

// 演唱会模式
class Concert extends StatefulWidget {
  const Concert({super.key});

  @override
  State<Concert> createState() => _ConcertState();
}

class _ConcertState extends State<Concert> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setPreferredOrientations([]);

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentIndex = lyricManager.currentIndex.watch(context),
        parsedLyric = lyricManager.parsedLyric.watch(context);

    return SafeArea(
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeInSine,
        switchOutCurve: Curves.easeOutSine,
        transitionBuilder: (Widget child, Animation<double> animation) =>
            FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(2, 0),
                  end: const Offset(0, 0),
                ).animate(animation),
                child: ScaleTransition(scale: animation, child: child),
              ),
            ),
        duration: AppTheme.defaultDurationLong,
        child: Align(
          key: currentIndex != -1 ? ValueKey(currentIndex) : null,
          alignment: Alignment.center,
          child: Text(
            currentIndex != -1 && parsedLyric.isNotEmpty
                ? parsedLyric[currentIndex].text
                : "暂无歌词",
            style: theme.textTheme.titleLarge?.copyWith(
              leadingDistribution: TextLeadingDistribution.even,
              decoration: TextDecoration.none,
              color: Colors.white,
              fontSize: 66,
            ),
            textAlign: .center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ),
    );
  }
}
