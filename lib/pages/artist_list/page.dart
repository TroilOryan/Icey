part of 'controller.dart';

class ArtistListPage extends StatefulWidget {
  const ArtistListPage({super.key});

  @override
  State<ArtistListPage> createState() => _ArtistListPageState();
}

final artistListController = ArtistListController();

class _ArtistListPageState extends State<ArtistListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();

    artistListController.onInit();
  }

  void _showColumnCountPicker() {
    final current = artistListController.state.crossAxisCount.value;
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
                    artistListController.state.crossAxisCount.value = count;
                    Boxes.settingsBox.put(
                      CacheKey.Settings.artistCrossAxisCount,
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

    final artistList = mediaManager.artistList.watch(context),
        coverList = artistListController.state.coverList.watch(context),
        crossAxisCount =
            artistListController.state.crossAxisCount.watch(context);

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
      title: "艺术家",
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
        controller: homeController.artistListScrollController,
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
                    childCount: artistList.length,
                    (context, index) {
                      final artist = artistList[index];

                      final artistCover = cover(artist.id);

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => context.push(
                              "/artist_list_detail/${artist.id}",
                              extra: {
                                "name": artist.name,
                                "cover": cover(artist.id),
                                "mediaIDs": artist.mediaIDs,
                              },
                            ),
                            child: Hero(
                              tag: "artistCover_${artist.id}",
                              child: artistCover != null
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
                                        artistCover,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : MediaCover(
                                      id: PlatformHelper.isDesktop
                                          ? artist.mediaIDs.first
                                          : artist.id,
                                      size: itemWidth,
                                      type: PlatformHelper.isDesktop
                                          ? ArtworkType.AUDIO
                                          : ArtworkType.ARTIST,
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.borderRadiusSm,
                                      ),
                                      onQueried: (v) => artistListController
                                          .handleQueried(v, artist.id),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Hero(
                            tag: "artistTitle_${artist.id}",
                            child: Text(
                              artist.name,
                              style: titleStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                          Text(
                            '${artist.mediaIDs.length}首',
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
