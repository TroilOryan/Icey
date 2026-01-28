part of 'controller.dart';

class MediaLibraryPage extends StatefulWidget {
  const MediaLibraryPage({super.key});

  @override
  State<MediaLibraryPage> createState() => _MediaLibraryPageState();
}

class _MediaLibraryPageState extends State<MediaLibraryPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final controller = MediaLibraryController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);

    final mediaList = mediaManager.mediaList.watch(context);

    final sortType = settingsManager.sortType.watch(context);

    final showDuration =
        sortType == MediaSort.duration || sortType == MediaSort.durationDesc;

    final noAzList = computed(
      () =>
          mediaList.isEmpty ||
          (sortType != MediaSort.title && sortType != MediaSort.artist),
    );

    final cursorInfo = controller.state.cursorInfo.watch(context);

    final paddingBottom = MediaQuery.of(context).padding.bottom;

    if (mediaList.isEmpty) {
      return MediaEmpty(onScan: MediaScanner.scanMedias);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SliverViewObserver(
          controller: homeController.observerController,
          sliverContexts: () => homeController.sliverContextMap.values.toList(),
          child: EasyRefresh(
            header: ClassicHeader(
              armedText: "松手即可刷新",
              dragText: "下拉刷新媒体库",
              readyText: "刷新中",
              processedText: "成功",
              showMessage: false,
              position: IndicatorPosition.locator,
              textStyle: theme.textTheme.bodyMedium,
            ),
            onRefresh: () => MediaScanner.scanMedias(true),
            child: CustomScrollView(
              controller: homeController.mediaListScrollController,
              slivers: [
                MultiSliver(
                  children: <Widget>[
                    HeaderLocator.sliver(),

                    HeaderAppBar(
                      onPlayRandom: homeController.handlePlayRandom,
                      onOpenSortMenu: controller.handleOpenSortMenu,
                      onTap: homeController.handleBackTop,
                    ),

                    // MediaOrder(offstage: mediaList.isEmpty),
                    MediaList(
                      showDuration: showDuration,
                      mediaList: mediaList,
                      sliverContextMap: homeController.sliverContextMap,
                      onTap: homeController.handleMediaTap,
                      onLongPress: (media) =>
                          homeController.handleMediaLongPress(media, context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        MediaListCursor(
          offstage: noAzList(),
          cursorInfo: cursorInfo,
          indexBarWidth: controller.indexBarWidth,
        ),

        MediaListIndexBar(
          offstage: noAzList(),
          indexBarWidth: controller.indexBarWidth,
          onSelectionUpdate: controller.handleSelectionUpdate,
          onSelectionEnd: controller.handleSelectionEnd,
        ),

        MediaLocator(
          offstage: mediaList.isEmpty,
          onTap: homeController.handleLocate,
        ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
