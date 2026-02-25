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
    // TODO: implement initState
    super.initState();

    artistListController.onInit();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);

    final artistList = mediaManager.artistList.watch(context),
        coverList = artistListController.state.coverList.watch(context);

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

    return ProgressiveScrollview(
      backgroundColor: Colors.transparent,
      title: "艺术家",
      centerTitle: false,
      onTap: homeController.handleBackTop,
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
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                childCount: artistList.length,
                (context, index) {
                  final artist = artistList[index];

                  final artistCover = cover(artist.id);

                  return Column(
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
                                  height: 156,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      AppTheme.borderRadiusSm,
                                    ),
                                  ),
                                  child: Image.memory(
                                    artistCover,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : MediaCover(
                                  id: artist.id,
                                  size: 156,
                                  type: ArtworkType.ARTIST,
                                  borderRadius: BorderRadius.all(
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
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                      Text(
                        '${artist.mediaIDs.length}首',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  );
                },
              ),
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
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
