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
    // TODO: implement initState
    super.initState();

    albumListController.onInit();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);

    final albumList = mediaManager.albumList.watch(context),
        coverList = albumListController.state.coverList.watch(context);

    Uint8List? cover(BigInt id) {
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

    return CustomScrollView(
      controller: homeController.albumListScrollController,
      slivers: [
        // HeaderAppBar(
        //   offstage: albumList.isEmpty,
        //   onPlayRandom: () => {},
        //   onOpenSortMenu: () => {},
        // ),
        HeaderAppBar(onTap: homeController.handleBackTop),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, paddingBottom + 64),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(childCount: albumList.length, (
              context,
              index,
            ) {
              final album = albumList[index];

              final albumCover = cover(album.id);

              return Column(
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
                              height: 156,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  AppTheme.borderRadiusSm,
                                ),
                              ),
                              child: Image.memory(
                                albumCover,
                                fit: BoxFit.cover,
                              ),
                            )
                          : MediaCover(
                              id: album.id.toInt(),
                              size: 156,
                              type: ArtworkType.ALBUM,
                              borderRadius: BorderRadius.all(
                                AppTheme.borderRadiusSm,
                              ),
                              onQueried: (v) => albumListController
                                  .handleQueried(v, album.id),
                            ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Hero(
                    tag: "albumTitle_${album.id}",
                    child: Text(
                      album.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                  Text(
                    '${album.mediaIDs.length}首',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              );
            }),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            // gridDelegate: _mySliverGridDelegateWithMaxCrossAxisExtent(),
          ),
        ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
