part of 'controller.dart';

class AlbumListPage extends StatefulWidget {
  const AlbumListPage({super.key});

  @override
  State<AlbumListPage> createState() => _AlbumListPageState();
}

final albumListController = AlbumListController();

class _AlbumListPageState extends State<AlbumListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();

    albumListController.onInit();
  }

  void _showColumnCountPicker() {
    final current = albumListController.state.crossAxisCount.value;
    final options = PlatformHelper.isDesktop ? [4, 6, 8] : [2, 3, 4];

    scrollableBottomSheet(
      context: context,
      builder: (context) => [
        Text('每行列数', style: Theme.of(context).textTheme.titleMedium),
        ListCard(
          children: options
              .map(
                (count) => ListItem(
                  title: '$count 列',
                  trailing: current == count
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : const SizedBox(),
                  onTap: () {
                    albumListController.state.crossAxisCount.value = count;
                    Boxes.settingsBox.put(
                      CacheKey.Settings.albumCrossAxisCount,
                      count,
                    );
                    if (PlatformHelper.isDesktop) {
                      SmartDialog.dismiss();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);

    final albumList = mediaManager.albumList.watch(context),
        coverList = albumListController.state.coverList.watch(context),
        crossAxisCount = albumListController.state.crossAxisCount.watch(context);

    Uint8List? cover(String id) {
      final index = coverList.indexWhere((e) => e.id == id);

      if (index != -1) {
        return coverList[index].cover;
      }

      return null;
    }

    final mediaQuery = MediaQuery.of(context);

    final paddingBottom = mediaQuery.padding.bottom != 0
        ? mediaQuery.padding.bottom
        : 16;

    // 列数越多，字体越小
    final fontScale = crossAxisCount <= 2
        ? 1.0
        : crossAxisCount <= 3
            ? 0.85
            : 0.75;

    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: (theme.textTheme.titleMedium?.fontSize ?? 14) * fontScale,
    );

    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 12) * fontScale,
    );

    return ProgressiveScrollview(
      backgroundColor: Colors.transparent,
      title: "专辑",
      centerTitle: false,
      onTap: homeController.handleBackTop,
      action: [
        HeaderAppBarAction(
          icon: Icons.grid_view_rounded,
          onTap: _showColumnCountPicker,
        ),
      ],
      builder: (appbarHeight) => CustomScrollView(
        cacheExtent: 700,
        controller: homeController.albumListScrollController,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              24,
              appbarHeight,
              24,
              paddingBottom + 64,
            ),
            sliver: SliverLayoutBuilder(
              builder: (context, sliverConstraints) {
                const crossAxisSpacing = 12.0;
                const mainAxisSpacing = 12.0;
                final contentWidth = sliverConstraints.crossAxisExtent;
                final itemWidth = (contentWidth -
                        (crossAxisCount - 1) * crossAxisSpacing) /
                    crossAxisCount;

                // 根据字体缩放计算文本占用高度
                final titleHeight =
                    (theme.textTheme.titleMedium?.fontSize ?? 14) *
                        fontScale *
                        1.4;
                final subtitleHeight =
                    (theme.textTheme.bodyMedium?.fontSize ?? 12) *
                        fontScale *
                        1.4;
                final textHeight = 8 + titleHeight + subtitleHeight;
                final cellHeight = itemWidth + textHeight;
                final aspectRatio = itemWidth / cellHeight;

                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    childCount: albumList.length,
                    (context, index) {
                      final album = albumList[index];

                      final albumCover = cover(album.id);

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => context.push(
                              "/album_list_detail/${album.id}",
                              extra: {
                                "name": album.name,
                                "cover": cover(album.id),
                                "mediaIDs": album.mediaIDs,
                              },
                            ),
                            child: Hero(
                              tag: "albumCover_${album.id}",
                              child: albumCover != null
                                  ? Container(
                                      width: itemWidth,
                                      height: itemWidth,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.borderRadiusSm,
                                        ),
                                      ),
                                      child: Image.memory(
                                        albumCover,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : MediaCover(
                                      id: PlatformHelper.isDesktop
                                          ? album.mediaIDs.first
                                          : album.id,
                                      size: itemWidth,
                                      type: PlatformHelper.isDesktop
                                          ? ArtworkType.AUDIO
                                          : ArtworkType.ALBUM,
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.borderRadiusSm,
                                      ),
                                      onQueried: (v) => albumListController
                                          .handleQueried(v, album.id),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Hero(
                            tag: "albumTitle_${album.id}",
                            child: Text(
                              album.name,
                              style: titleStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                          Text(
                            '${album.mediaIDs.length}首',
                            style: subtitleStyle,
                          ),
                        ],
                      );
                    },
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: mainAxisSpacing,
                    crossAxisSpacing: crossAxisSpacing,
                    childAspectRatio: aspectRatio,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
