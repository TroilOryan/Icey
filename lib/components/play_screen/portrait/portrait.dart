import 'package:IceyPlayer/components/play_list_button/play_list.dart';
import 'package:IceyPlayer/components/play_menu_button/play_menu_button.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../play_immersive_cover/play_immersive_cover.dart';
import '../play_info/play_info.dart';
import 'lyric_page.dart';
import 'play_page.dart';

class Portrait extends StatefulWidget {
  final PageController pageController;
  final VoidCallback? onClose;
  final Function(BuildContext) onOpenLyric;
  final Function(BuildContext) onOpenPlaylist;

  const Portrait({
    super.key,
    required this.pageController,
    required this.onOpenLyric,
    required this.onOpenPlaylist,
    this.onClose,
  });

  @override
  State<Portrait> createState() => _PortraitState();
}

class _PortraitState extends State<Portrait> {
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(_onPageChanged);
  }

  @override
  void didUpdateWidget(covariant Portrait oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageController != widget.pageController) {
      oldWidget.pageController.removeListener(_onPageChanged);
      widget.pageController.addListener(_onPageChanged);
      _currentPage = widget.pageController.initialPage;
    }
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    final page = widget.pageController.page?.round();
    if (page != null && page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeExtension = AppThemeExtension.of(context);
    final immersive = settingsManager.immersive.watch(context);
    final coverShape = settingsManager.coverShape.watch(context);

    final isOnPlayPage = _currentPage == 1;
    final isImmersiveCover = coverShape == CoverShape.immersive;
    final hideTopInfo = (immersive || isImmersiveCover) && isOnPlayPage;

    final deviceWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // 沉浸封面：从屏幕最顶部开始（在 SafeArea 之外）
        if (isImmersiveCover && isOnPlayPage)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: PlayImmersiveCover(size: deviceWidth),
          ),
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 顶部固定：播放信息 + 菜单按钮
              AnimatedOpacity(
                opacity: hideTopInfo ? 0 : 1,
                duration: AppTheme.defaultDuration,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 32, 12, 0),
                  child: Row(
                    children: [
                      const Expanded(child: PlayInfo()),
                      const SizedBox(width: 8),
                      PlayMenuButton(size: 24, color: themeExtension.primary),
                    ],
                  ),
                ),
              ),
              // PageView：播放列表 / 播放内容 / 歌词
              Expanded(
                child: PageView(
                  controller: widget.pageController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Page 0: 播放列表
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 32, 16, 0),
                      child: PlayList(),
                    ),
                    // Page 1 (默认): 播放内容
                    PlayPage(onOpenLyric: widget.onOpenLyric),
                    // Page 2: 歌词页
                    const LyricPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
