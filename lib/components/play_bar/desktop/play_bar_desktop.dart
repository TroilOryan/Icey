part of '../controller.dart';

class PlayBarDesktop extends StatelessWidget {
  final bool hidePlayBar;
  final VoidCallback onTap;

  const PlayBarDesktop({
    super.key,
    required this.hidePlayBar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final deviceWidth = MediaQuery.of(context).size.width;

    final double paddingBottom = max(
      MediaQuery.of(context).viewPadding.bottom,
      16,
    );

    final playBar = Container(
      padding: const .fromLTRB(10, 8, 6, 8),
      child: Stack(
        children: [
          Row(
            spacing: 8,
            children: [
              Container(
                clipBehavior: .antiAlias,
                decoration: BoxDecoration(borderRadius: .circular(66)),
                child: PlayCover(
                  width: 48,
                  height: 48,
                  borderRadius: .circular(66),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) =>
                          FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          ),
                  duration: AppTheme.defaultDurationMid,
                ),
              ),
              const PlayInfo(),
            ],
          ),

          AdaptiveBuilder(
            mobile: (context) => Align(
              alignment: .center,
              child: Row(
                mainAxisAlignment: .center,
                children: [
                  PlayModeButton(size: 18, color: theme.colorScheme.onSurface),
                  PrevButton(size: 18, color: theme.colorScheme.onSurface),
                  PlayButton(
                    size: 21,
                    ghost: true,
                    color: theme.colorScheme.onSurface,
                  ),
                  NextButton(size: 18, color: theme.colorScheme.onSurface),
                  PlayListButton(size: 18, color: theme.colorScheme.onSurface),
                ],
              ),
            ),
            tablet: (context) => Align(
              alignment: .center,
              child: Row(
                mainAxisAlignment: .end,
                children: [
                  PlayModeButton(size: 18, color: theme.colorScheme.onSurface),
                  PrevButton(size: 18, color: theme.colorScheme.onSurface),
                  PlayButton(
                    size: 21,
                    ghost: true,
                    color: theme.colorScheme.onSurface,
                  ),
                  NextButton(size: 18, color: theme.colorScheme.onSurface),
                  PlayListButton(size: 18, color: theme.colorScheme.onSurface),
                ],
              ),
            ),
            desktop: (context) => Align(
              alignment: .center,
              child: Row(
                mainAxisAlignment: .center,
                children: [
                  PlayModeButton(size: 18, color: theme.colorScheme.onSurface),
                  PrevButton(size: 18, color: theme.colorScheme.onSurface),
                  PlayButton(
                    size: 21,
                    ghost: true,
                    color: theme.colorScheme.onSurface,
                  ),
                  NextButton(size: 18, color: theme.colorScheme.onSurface),
                  PlayListButton(size: 18, color: theme.colorScheme.onSurface),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return FrameSeparateWidget(
      child: GestureDetector(
        onTap: onTap,
        behavior: .opaque,
        child: AnimatedSlide(
          curve: Curves.easeInOutSine,
          offset: Offset(0, hidePlayBar ? 1 : 0),
          duration: AppTheme.defaultDurationLong,
          child: GlassPanel(
            width: deviceWidth * 0.62,
            height: playBarController.playBarHeight,
            shape: const LiquidRoundedRectangle(borderRadius: 66),
            padding: .zero,
            settings: RecommendedGlassSettings.bottomBar,
            margin: .fromLTRB(16, 0, 16, paddingBottom),
            child: playBar,
          ),
        ),
      ),
    );
  }
}
