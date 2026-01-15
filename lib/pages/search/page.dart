import 'package:extended_image/extended_image.dart';
import 'package:IceyPlayer/components/media_list_tile/media_list_tile.dart';
import 'package:IceyPlayer/components/page_wrapper/page_wrapper.dart';
import 'package:IceyPlayer/entities/media.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:IceyPlayer/pages/home/controller.dart';
import 'package:pinyin/pinyin.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'state.dart';

part 'controller.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = SearchController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller.onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    controller.onDispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final keyword = controller.state.keyword.watch(context),
        mediaList = controller.state.mediaList.watch(context);

    return PageWrapper(
      title: '搜索',
      body: MultiSliver(
        children: [
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              child: TextField(
                focusNode: controller.focusNode,
                onChanged: controller.handleChanged,
                decoration: InputDecoration(
                  fillColor: theme.cardTheme.color,
                  prefixIcon: Icon(SFIcons.sf_magnifyingglass, size: 16),
                  hint: Text(
                    "Search...",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: mediaList.isEmpty
                ? ExtendedImage.asset("assets/images/empty.png")
                : Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      "共${mediaList.length}个",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
          ),

          StreamBuilder(
            stream: mediaManager.mediaItem,
            builder: (context, snapshot) {
              final mediaItem = snapshot.data;

              return SuperSliverList.separated(
                itemBuilder: (context, index) {
                  final media = mediaList[index];

                  final isPlaying = mediaItem?.id == media.id.toString();

                  return MediaListTile(
                    media,
                    obscure: false,
                    isPlaying: isPlaying,
                    onTap: () => homeController.handleMediaTap(media),
                    onLongPress: () =>
                        controller.handleMediaLongPress(media, context),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(height: 16),
                itemCount: mediaList.length,
              );
            },
          ),
        ],
      ),
    );
  }
}
