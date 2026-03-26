part of '../controller.dart';

final playBarController = PlayBarController();

class PlayBarMobile extends StatelessWidget {
  final bool hidePlayBar;
  final VoidCallback onTap;

  const PlayBarMobile({
    super.key,
    required this.hidePlayBar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final double paddingBottom = max(
      MediaQuery.of(context).viewPadding.bottom,
      16,
    );

    final delta = playBarController.state.delta.watch(context),
        isNext = playBarController.state.isNext.watch(context);

    final playBar = Container(
      padding: .fromLTRB(10, 8, 6, 8),
      child: Stack(
        children: [
          StreamBuilder(
            stream: mediaManager.queue,
            builder: (context, snapshot) {
              final queue = snapshot.data ?? [];

              return StreamBuilder(
                stream: mediaManager.mediaItem,
                builder: (context, snapshot) {
                  final mediaItem = snapshot.data;

                  final index = mediaItem != null
                      ? queue.indexOf(mediaItem)
                      : -1;

                  final prevIndex = index == 0 ? queue.length - 1 : index - 1;

                  final nextIndex = index == queue.length - 1 ? 0 : index + 1;

                  return Transform.translate(
                    offset: Offset(delta, 0),
                    child: LayoutBuilder(
                      builder: (context, constraints) => Stack(
                        clipBehavior: .none,
                        alignment: .center,
                        children: [
                          Positioned(
                            right: constraints.maxWidth - 8 - 35.2,
                            child: VisibilityDetector(
                              key: Key("prev"),
                              onVisibilityChanged:
                                  playBarController.handleVisibilityChanged,
                              child: Offstage(
                                offstage: isNext != -1 || queue.isEmpty,
                                child: SizedBox(
                                  width: constraints.maxWidth / 3,
                                  child: Column(
                                    crossAxisAlignment: .end,
                                    mainAxisAlignment: .center,
                                    children: [
                                      Text(
                                        queue.isNotEmpty
                                            ? queue[prevIndex].title
                                            : "",
                                        style: theme.textTheme.titleSmall,
                                        textAlign: .right,
                                        overflow: .ellipsis,
                                        maxLines: 1,
                                        softWrap: true,
                                      ),
                                      Text(
                                        "上一首",
                                        textAlign: .right,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              leadingDistribution: .even,
                                              decoration: .none,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          PlayInfo(),
                          Positioned(
                            left: constraints.maxWidth - 8 - 35.2,
                            child: VisibilityDetector(
                              key: Key("next"),
                              onVisibilityChanged:
                                  playBarController.handleVisibilityChanged,
                              child: Offstage(
                                offstage: isNext != 1 || queue.isEmpty,
                                child: Column(
                                  crossAxisAlignment: .start,
                                  mainAxisAlignment: .center,
                                  children: [
                                    Text(
                                      queue.isNotEmpty
                                          ? queue[nextIndex].title
                                          : "",
                                      style: theme.textTheme.titleSmall,
                                      overflow: .ellipsis,
                                      maxLines: 1,
                                      softWrap: true,
                                    ),
                                    Text(
                                      "下一首",
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            leadingDistribution: .even,
                                            decoration: .none,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Container(
            clipBehavior: .antiAlias,
            decoration: BoxDecoration(borderRadius: .circular(66)),
            child: PlayCover(
              width: 48,
              height: 48,
              borderRadius: .circular(66),
              transitionBuilder: (Widget child, Animation<double> animation) =>
                  FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
              duration: AppTheme.defaultDurationMid,
            ),
          ),
          Align(
            alignment: .centerRight,
            child: PlayProgressButton(
              size: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );

    return FrameSeparateWidget(
      child: GestureDetector(
        onTap: onTap,
        behavior: .opaque,
        onHorizontalDragUpdate: playBarController.handleHorizontalDragUpdate,
        onHorizontalDragEnd: playBarController.handleHorizontalDragEnd,
        child: AnimatedSlide(
          curve: Curves.easeInOutSine,
          offset: Offset(0, hidePlayBar ? 1 : 0),
          duration: AppTheme.defaultDurationLong,
          child: GlassPanel(
            height: playBarController.playBarHeight,
            shape: LiquidRoundedRectangle(borderRadius: 66),
            padding: .zero,
            settings: RecommendedGlassSettings.bottomBar.copyWith(blur: 5),
            margin: .fromLTRB(16, 0, 16, paddingBottom + 64 + 12),
            child: playBar,
          ),
        ),
      ),
    );
  }
}
