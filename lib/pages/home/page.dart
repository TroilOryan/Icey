part of 'controller.dart';

final homeController = HomeController();

class HomePage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const HomePage({super.key, required this.navigationShell});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    homeController.onInit(context, widget.navigationShell, this);

    super.initState();
  }

  @override
  void dispose() {
    homeController.onDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final deviceWidth = MediaQuery.of(context).size.width;

    final deviceHeight = MediaQuery.of(context).size.height;

    final mediaList = mediaManager.mediaList.watch(context);

    final listBg = settingsManager.listBg.watch(context);

    final panelOpened = homeController.state.panelOpened.watch(context),
        sideBarOpened = homeController.state.sideBarOpened.watch(context),
        hidePlayBar = homeController.state.hidePlayBar.watch(context);

    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    final content = Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: listBg.isNotEmpty
          ? Colors.transparent
          : theme.scaffoldBackgroundColor,
      bottomNavigationBar: mediaList.isNotEmpty
          ? AnimatedBuilder(
              animation: homeController.panelAnimController,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, homeController.panelAnimController.value * 200),
                child: child,
              ),
              child: BottomBar(
                menu: homeController.menu,
                selectedIndex: widget.navigationShell.currentIndex,
                onSearch: () => homeController.navToSearch(context),
                onTabSelected: (index) => homeController.handleGoBranch(index),
              ),
            )
          : null,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          widget.navigationShell,

          if (mediaList.isNotEmpty)
            AnimatedBuilder(
              animation: homeController.panelAnimController,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, homeController.panelAnimController.value * 200),
                child: child,
              ),
              child: PlayBarMobile(
                hidePlayBar: hidePlayBar,
                onTap: () => homeController.handleOpenPanel(),
                onVerticalDragUpdate: (details) =>
                    homeController.handlePlayBarVerticalDragUpdate(
                      details,
                      deviceHeight,
                    ),
                onVerticalDragEnd: (details) =>
                    homeController.handlePlayBarVerticalDragEnd(
                      details,
                      deviceHeight,
                    ),
              ),
            ),

          // 播放页覆盖层（通过 AnimationController 驱动，支持手势跟随）
          if (mediaList.isNotEmpty)
            AnimatedBuilder(
              animation: homeController.panelAnimController,
              builder: (context, child) => Transform.translate(
                offset: Offset(
                  0,
                  (1 - homeController.panelAnimController.value) * deviceHeight,
                ),
                child: child,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0) {
                    homeController.handlePlayScreenVerticalDragUpdate(
                      details.delta.dy,
                      deviceHeight,
                    );
                  }
                },
                onVerticalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dy > 300 ||
                      homeController.panelAnimController.value < 0.5) {
                    homeController.handleClosePanel();
                  } else {
                    homeController.handleOpenPanel();
                  }
                },
                child: PlayScreen(
                  onClose: () => homeController.handleClosePanel(),
                ),
              ),
            ),
        ],
      ),
    );

    final mobile = listBg.isNotEmpty
        ? LiquidGlassScope.stack(
            background: Stack(
              children: [
                Image.memory(
                  listBg,
                  fit: BoxFit.cover,
                  width: deviceWidth,
                  height: deviceHeight,
                  gaplessPlayback: true,
                ),
                Offstage(
                  offstage: !isDarkMode,
                  child: Container(
                    color: Colors.black45,
                    width: deviceWidth,
                    height: deviceHeight,
                  ),
                ),
              ],
            ),
            content: content,
          )
        : content;

    return AdaptiveBuilder(
      mobile: (context) => PopScope(
        canPop: !panelOpened,
        onPopInvokedWithResult: homeController.handlePopInvokedWithResult,
        child: mobile,
      ),
      tablet: (context) => PopScope(
        canPop: !panelOpened,
        onPopInvokedWithResult: homeController.handlePopInvokedWithResult,
        child: Scaffold(
          backgroundColor: listBg.isNotEmpty
              ? Colors.transparent
              : theme.scaffoldBackgroundColor,
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              if (listBg.isNotEmpty)
                Stack(
                  children: [
                    Image.memory(
                      listBg,
                      fit: BoxFit.cover,
                      width: deviceWidth,
                      height: deviceHeight,
                      gaplessPlayback: true,
                    ),
                    Offstage(
                      offstage: !isDarkMode,
                      child: Container(
                        color: Colors.black45,
                        width: deviceWidth,
                        height: deviceHeight,
                      ),
                    ),
                  ],
                ),
              Row(
                children: [
                  SideBar(
                    menu: homeController.menu,
                    opened: sideBarOpened,
                    selectedIndex: widget.navigationShell.currentIndex,
                    onTabSelected: (index) =>
                        homeController.handleGoBranch(index),
                  ),
                  Flexible(child: widget.navigationShell),
                ],
              ),
              if (mediaList.isNotEmpty)
                PlayBarDesktop(
                  hidePlayBar: hidePlayBar,
                  onTap: () => homeController.handleOpenPanel(),
                ),
              if (PlatformHelper.isDesktop)
                TitleBarAction(sideBarOpened: sideBarOpened),

              // 播放页覆盖层（通过 AnimationController 驱动，支持手势跟随）
              if (mediaList.isNotEmpty)
                AnimatedBuilder(
                  animation: homeController.panelAnimController,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(
                      0,
                      (1 - homeController.panelAnimController.value) * deviceHeight,
                    ),
                    child: child,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragUpdate: (details) {
                      if (details.delta.dy > 0) {
                        homeController.handlePlayScreenVerticalDragUpdate(
                          details.delta.dy,
                          deviceHeight,
                        );
                      }
                    },
                    onVerticalDragEnd: (details) {
                      if (details.velocity.pixelsPerSecond.dy > 300 ||
                          homeController.panelAnimController.value < 0.5) {
                        homeController.handleClosePanel();
                      } else {
                        homeController.handleOpenPanel();
                      }
                    },
                    child: PlayScreen(
                      onClose: () => homeController.handleClosePanel(),
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
