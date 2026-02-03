part of 'controller.dart';

class ArtistListDetailPage extends StatelessWidget {
  const ArtistListDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ArtistListDetailController();

    final theme = Theme.of(context);

    final mediaQuery = MediaQuery.of(context);

    final deviceWidth = mediaQuery.size.width,
        deviceHeight = mediaQuery.size.height;

    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;

    final name = extra?["name"] as String,
        cover = extra?["cover"] as Uint8List?,
        mediaIDs = extra?["mediaIDs"] as List<int>;

    final id = int.parse(GoRouterState.of(context).pathParameters["id"]!);

    final mediaList = mediaManager.mediaList.watch(context);

    final artistList = computed(
      () => mediaList.where((e) => mediaIDs.contains(e.id)).toList(),
    );

    final duration = computed(
      () => artistList
          .map((e) => e.duration)
          .reduce((a, b) => (a ?? 0) + (b ?? 0)),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Blur(
            blur: 32,
            blurColor: theme.scaffoldBackgroundColor,
            child: cover != null
                ? Image.memory(
                    cover,
                    fit: BoxFit.cover,
                    width: deviceWidth,
                    height: deviceHeight,
                  )
                : MediaCover(
                    id: id,
                    size: deviceWidth,
                    width: deviceWidth,
                    height: deviceHeight,
                    type: ArtworkType.ARTIST,
                  ),
          ),

          PageWrapper(
            title: "",
            backgroundColor: Colors.transparent,
            body: MultiSliver(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Hero(
                      tag: "artistCover_$id",
                      child: Container(
                        height: 156,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            AppTheme.borderRadiusSm,
                          ),
                        ),
                        child: cover != null
                            ? Image.memory(cover, fit: BoxFit.cover)
                            : MediaCover(
                                id: id,
                                type: ArtworkType.ARTIST,
                                size: 156,
                                borderRadius: BorderRadius.all(
                                  AppTheme.borderRadiusSm,
                                ),
                              ),
                      ),
                    ),
                    Hero(
                      tag: "artistTitle_$id",
                      child: Text(
                        name,
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    Row(
                      spacing: 64,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LabelValue(
                          label: "歌曲",
                          value: mediaIDs.length.toString(),
                        ),
                        LabelValue(
                          label: "时长",
                          value: duration() != null
                              ? CommonHelper.buildDurationText(
                                  Duration(milliseconds: duration()!),
                                )
                              : "-",
                        ),
                        LabelValue(
                          label: "年份",
                          value:
                              artistList().first.year != null &&
                                  artistList().first.year != 0
                              ? artistList().first.year.toString()
                              : "-",
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Material(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          clipBehavior: Clip.antiAlias,
                          type: MaterialType.transparency,
                          child: Ink(
                            child: InkWell(
                              onTap: () =>
                                  controller.handlePlayAll(artistList()),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment:
                                            ui.PlaceholderAlignment.middle,
                                        child: SFIcon(
                                          SFIcons.sf_play_circle_fill,
                                          color: theme.colorScheme.primary,
                                          fontSize: 22,
                                        ),
                                      ),
                                      WidgetSpan(
                                        alignment:
                                            ui.PlaceholderAlignment.middle,
                                        child: Text(
                                          " 播放全部 ",
                                          style: theme.textTheme.titleSmall!
                                              .copyWith(height: 1.5),
                                        ),
                                      ),
                                      WidgetSpan(
                                        alignment:
                                            ui.PlaceholderAlignment.middle,
                                        child: Text(
                                          "(${artistList().length})",
                                          style: theme.textTheme.bodyLarge!
                                              .copyWith(height: 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                StreamBuilder(
                  stream: mediaManager.mediaItem,
                  builder: (context, snapshot) {
                    final mediaItem = snapshot.data;

                    return SuperSliverList.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemCount: artistList().length,
                      itemBuilder: (context, index) {
                        final media = artistList()[index];

                        final isPlaying = mediaItem?.id == media.id.toString();

                        return MediaListTile(
                          media,
                          forceObscure: true,
                          isPlaying: isPlaying,
                          onTap: () => homeController.handleMediaTap(media),
                          onLongPress: () => homeController
                              .handleMediaLongPress(media, context),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
