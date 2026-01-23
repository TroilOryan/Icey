import 'package:IceyPlayer/constants/glass_settings.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:IceyPlayer/components/play_cover/play_cover.dart';
import 'package:IceyPlayer/components/play_progress_button/play_progress_button.dart';
import 'package:IceyPlayer/components/play_screen/play_screen.dart';
import 'package:IceyPlayer/components/sliding_up_panel/sliding_up_panel.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';
import 'package:keframe/keframe.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../theme/theme.dart';
import './play_info.dart';

part 'controller.dart';

part 'state.dart';

final playBarController = PlayBarController();

class PlayBar extends StatelessWidget {
  final PanelController controller;
  final bool hidePlayBar;
  final Widget body;
  final bool isDraggable;
  final bool panelOpened;
  final double panelSlideValue;
  final VoidCallback onPanelOpened;
  final VoidCallback onPanelClosed;
  final Function(double) onPanelSlide;
  final VoidCallback onClosePanel;

  const PlayBar({
    super.key,
    required this.body,
    required this.hidePlayBar,
    required this.isDraggable,
    required this.controller,
    required this.panelOpened,
    required this.panelSlideValue,
    required this.onPanelOpened,
    required this.onPanelClosed,
    required this.onPanelSlide,
    required this.onClosePanel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final deviceHeight = MediaQuery.of(context).size.height;

    final paddingBottom = MediaQuery.of(context).padding.bottom;

    final delta = playBarController.state.delta.watch(context),
        isNext = playBarController.state.isNext.watch(context);

    return StreamBuilder(
      stream: mediaManager.mediaItem,
      builder: (context, snapshot) {
        return SlidingUpPanel(
          color: Colors.transparent,
          boxShadow: [],
          isDraggable: isDraggable,
          controller: controller,
          minHeight: !isDraggable || hidePlayBar
              ? 0
              : max(94 + paddingBottom, 104),
          maxHeight: deviceHeight,
          onPanelOpened: onPanelOpened,
          onPanelClosed: onPanelClosed,
          onPanelSlide: onPanelSlide,
          panel: FrameSeparateWidget(
            child: PlayScreen(
              panelOpened: panelOpened,
              onClosePanel: onClosePanel,
            ),
          ),
          body: FrameSeparateWidget(child: body),
          collapsed: FrameSeparateWidget(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate:
                  playBarController.handleHorizontalDragUpdate,
              onHorizontalDragEnd: playBarController.handleHorizontalDragEnd,
              child: GlassPanel(
                padding: EdgeInsets.zero,
                settings: RecommendedGlassSettings.overlay,
                margin: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  paddingBottom == 0 ? 16 : paddingBottom,
                ),
                child: Container(
                  height: 88,
                  padding: EdgeInsets.fromLTRB(16, 16, 12, 16),
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

                              final prevIndex = index == 0
                                  ? queue.length - 1
                                  : index - 1;

                              final nextIndex = index == queue.length - 1
                                  ? 0
                                  : index + 1;

                              return Transform.translate(
                                offset: Offset(delta, 0),
                                child: LayoutBuilder(
                                  builder: (context, constraints) => Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned(
                                        right: constraints.maxWidth - 16 - 35.2,
                                        child: VisibilityDetector(
                                          key: Key("prev"),
                                          onVisibilityChanged: playBarController
                                              .handleVisibilityChanged,
                                          child: Offstage(
                                            offstage:
                                                isNext != -1 || queue.isEmpty,
                                            child: SizedBox(
                                              child: SizedBox(
                                                width: constraints.maxWidth / 3,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      queue.isNotEmpty
                                                          ? queue[prevIndex]
                                                                .title
                                                          : "",
                                                      style: theme
                                                          .textTheme
                                                          .titleSmall,
                                                      textAlign:
                                                          TextAlign.right,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      softWrap: true,
                                                    ),
                                                    Text(
                                                      "上一首",
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            leadingDistribution:
                                                                TextLeadingDistribution
                                                                    .even,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      PlayInfo(
                                        mediaItem: mediaItem,
                                        panelOpened: panelOpened,
                                      ),
                                      Positioned(
                                        left: constraints.maxWidth - 16 - 35.2,
                                        child: VisibilityDetector(
                                          key: Key("next"),
                                          onVisibilityChanged: playBarController
                                              .handleVisibilityChanged,
                                          child: Offstage(
                                            offstage:
                                                isNext != 1 || queue.isEmpty,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  queue.isNotEmpty
                                                      ? queue[nextIndex].title
                                                      : "",
                                                  style: theme
                                                      .textTheme
                                                      .titleSmall,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  softWrap: true,
                                                ),
                                                Text(
                                                  "下一首",
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        leadingDistribution:
                                                            TextLeadingDistribution
                                                                .even,
                                                        decoration:
                                                            TextDecoration.none,
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
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            AppTheme.borderRadiusXs,
                          ),
                        ),
                        child: PlayCover(
                          width: 56,
                          height: 56,
                          borderRadius: BorderRadius.all(
                            AppTheme.borderRadiusXs,
                          ),
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: PlayProgressButton(
                          size: 18,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
