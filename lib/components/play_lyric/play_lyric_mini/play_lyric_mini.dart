part of 'controller.dart';

class PlayLyricMini extends StatefulWidget {
  final Color? color;
  final VoidCallback? onTap;

  const PlayLyricMini({super.key, this.color, this.onTap});

  @override
  State<PlayLyricMini> createState() => _PlayLyricMiniState();
}

class _PlayLyricMiniState extends State<PlayLyricMini> {
  final controller = PlayLyricMiniController();

  @override
  void initState() {
    controller.onInit();

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    controller.onDispose();

    // TODO: implement dispose
    super.dispose();
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

    return FrameSeparateWidget(
      child: GestureDetector(
        onTap: widget.onTap,
        child: Builder(
          builder: (context) {
            final parsedLyric = lyricManager.parsedLyric.watch(context),
                currentIndex = lyricManager.currentIndex.watch(context);

            final lineHeight =
                textStyle.fontSize! * textStyle.height! + 4; // 包含上下padding各2

            final containerHeight = lineHeight * 2; // 正好容纳两行

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
                        listController: controller.listviewController,
                        controller: controller.scrollController,
                        itemCount: parsedLyric.length,
                        itemBuilder: (context, index) =>
                            controller.buildLyricItem(
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
      ),
    );
  }
}
