part of 'controller.dart';

// 悬浮歌词
class PlayLyricOverlay extends StatefulWidget {
  const PlayLyricOverlay({super.key});

  @override
  State<PlayLyricOverlay> createState() => _PlayLyricOverlayState();
}

class _PlayLyricOverlayState extends State<PlayLyricOverlay> {
  final controller = PlayLyricOverlayController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller.onInit();
  }

  @override
  void dispose() {
    controller.onDispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lyric = controller.state.lyric.watch(context),
        duration = controller.state.duration.watch(context),
        width = controller.state.width.watch(context),
        playing = controller.state.playing.watch(context),
        visible = controller.state.visible.watch(context);

    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: AppTheme.defaultDuration,
      child: Material(
        type: MaterialType.transparency,
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width),
          child: Stack(
            children: [
              SizedBox(
                width: width,
                child: Marquee(
                  gap: 50,
                  delay: const Duration(milliseconds: 1000),
                  duration: Duration(milliseconds: duration + 2000),
                  disableAnimation: !playing,
                  child: Text(
                    lyric.isEmpty ? "暂无歌词" : lyric,
                    style: controller.state.textStyle(),
                    maxLines: 1,
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
