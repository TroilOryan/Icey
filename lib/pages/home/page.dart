part of 'controller.dart';

final homeController = HomeController();

class HomePage extends StatefulWidget {
  // final StatefulNavigationShell navigationShell;

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    homeController.onInit(context);

    homeController.rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      reverseDuration: const Duration(milliseconds: 100),
      vsync: this,
    );

    mediaManager.rotationAnimation.value = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(homeController.rotationController);

    homeController.lifecycleListener = AppLifecycleListener(
      onShow: () {
        if (mediaManager.isPlaying) {
          homeController.rotationController.forward();
        }

        homeController.mediaItemListener.resume();

        if (homeController.currentMediaItem != mediaManager.mediaItem.value) {
          homeController.rotationController.reverse();
          homeController.currentMediaItem = mediaManager.mediaItem.value;
        }
      },
      onHide: () {
        homeController.rotationController.stop();

        homeController.mediaItemListener.pause();
      },
    );

    homeController.mediaItemListener = mediaManager.mediaItem.listen((
      mediaItem,
    ) {
      if (homeController.currentMediaItem != mediaItem) {
        homeController.rotationController.reverse();
        homeController.currentMediaItem = mediaItem;
      }
    });

    mediaManager.playbackState.map((state) => state.playing).listen((playing) {
      if (playing == true &&
          homeController.rotationController.isAnimating == false) {
        homeController.rotationController.repeat();
      } else if (playing == false &&
          homeController.rotationController.isAnimating == true) {
        homeController.rotationController.stop();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    homeController.onDispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final deviceWidth = MediaQuery.of(context).size.width;

    final deviceHeight = MediaQuery.of(context).size.height;

    final mediaList = mediaManager.mediaList.watch(context);

    final listBg = settingsManager.listBg.watch(context),
        listType = settingsManager.listType.watch(context);

    final isMediaList = computed(() => listType == ListType.media);

    final panelOpened = homeController.state.panelOpened.watch(context),
        panelSlideValue = homeController.state.panelSlideValue.watch(context),
        hidePlayBar = homeController.state.hidePlayBar.watch(context);

    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return PopScope(
      canPop: !panelOpened && panelSlideValue == 0,
      onPopInvokedWithResult: homeController.handlePopInvokedWithResult,
      child: Stack(
        children: [
          if (listBg.isNotEmpty)
            Stack(
              children: [
                Image.memory(
                  listBg,
                  fit: BoxFit.cover,
                  width: deviceWidth,
                  height: deviceHeight,
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
          Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: listBg.isNotEmpty
                ? Colors.transparent
                : theme.scaffoldBackgroundColor,
            body: PlayBar(
              body: DefaultTabController(
                length: 3,
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    if (orientation == Orientation.landscape) {
                      return Landscape();
                    }

                    return CustomScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      slivers: [
                        MultiSliver(
                          pushPinnedChildren: true,
                          children: [
                            HeaderAppBar(
                              offstage: mediaList.isEmpty,
                              onPlayRandom: homeController.handlePlayRandom,
                              onOpenSortMenu: () =>
                                  eventBus.fire(OpenSortMenu()),
                            ),
                            HeaderTabBar(
                              offstage: mediaList.isEmpty,
                              onTap: (v) =>
                                  homeController.handleSelected(v, context),
                            ),
                          ],
                        ),

                        SliverFillRemaining(
                          child: TabBarView(
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              MediaLibraryPage(),
                              AlbumListPage(),
                              ArtistListPage(),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              hidePlayBar: hidePlayBar,
              isDraggable: mediaList.isNotEmpty,
              controller: homeController.panelController,
              panelOpened: panelOpened,
              panelSlideValue: panelSlideValue,
              onPanelOpened: homeController.handlePanelOpened,
              onPanelClosed: homeController.handlePanelClosed,
              onPanelSlide: homeController.handlePanelSlide,
              onClosePanel: homeController.handleClosePanel,
            ),
          ),
        ],
      ),
    );
  }
}
