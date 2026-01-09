import 'dart:typed_data';

import 'package:audio_query/audio_query.dart';
import 'package:audio_query/types/artwork_type.dart';
import 'package:audio_service/audio_service.dart';
import 'package:IceyPlayer/components/bottom_sheet/bottom_sheet.dart';
import 'package:IceyPlayer/components/button/button.dart';
import 'package:IceyPlayer/components/icey_switch/icey_switch.dart';
import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/components/media_list_tile/media_list_tile.dart';
import 'package:IceyPlayer/components/media_more_sheet/media_more_sheet.dart';
import 'package:IceyPlayer/components/round_icon_button/round_icon_button.dart';
import 'package:IceyPlayer/components/sheet_item/sheet_item.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/entities/media.dart';
import 'package:IceyPlayer/entities/media_order.dart';
import 'package:IceyPlayer/event_bus/event_bus.dart';
import 'package:IceyPlayer/helpers/image.dart';
import 'package:IceyPlayer/helpers/toast/toast.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/pages/home/controller.dart';
import 'package:IceyPlayer/pages/media_order_detail/state.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'dart:ui' as ui;

part 'controller.dart';

final _mediaOrderBox = Boxes.mediaOrderBox, _likedBox = Boxes.likedBox;

class MediaOrderDetailPage extends StatefulWidget {
  const MediaOrderDetailPage({super.key});

  @override
  State<MediaOrderDetailPage> createState() => _MediaOrderDetailPageState();
}

class _MediaOrderDetailPageState extends State<MediaOrderDetailPage> {
  final controller = MediaOrderDetailController();

  void onInit() {
    if (context.mounted) {
      controller.mediaOrderID = GoRouterState.of(context).pathParameters["id"]!;

      if (controller.mediaOrderID == "0") {
        final liked = _likedBox.keys.toList();

        controller.state.mediaList.value = List.unmodifiable(
          mediaManager.localMediaList.where((e) => liked.contains(e.id)),
        );
      } else {
        final MediaOrderEntity mediaOrder = _mediaOrderBox.get(
          controller.mediaOrderID,
        );

        controller.state.mediaList.value = List.unmodifiable(
          mediaManager.localMediaList.where(
            (e) => mediaOrder.mediaIDs.contains(e.id),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onInit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final id = GoRouterState.of(context).pathParameters["id"]!;

    final extra = GoRouterState.of(context).extra as Map<String, dynamic>;

    /// 自定义封面和随机封面
    final cover = extra["cover"] as Uint8List,
        randomCover = extra["randomCover"] as Uint8List?;

    final name = extra["name"] as String;

    final mediaList = controller.state.mediaList.watch(context),
        tempCover = controller.state.tempCover.watch(context);

    final mediaQuery = MediaQuery.of(context);

    final paddingBottom = mediaQuery.padding.bottom != 0
        ? mediaQuery.padding.bottom
        : 16.h;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            centerTitle: true,
            scrolledUnderElevation: 0,
            backgroundColor: theme.appBarTheme.backgroundColor,
            title: Text(name, style: theme.textTheme.titleMedium),
            leading: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 36.sp,
                margin: EdgeInsets.fromLTRB(24.w, 4.h, 0, 0),
                child: RoundIconButton(
                  icon: const Icon(Icons.arrow_back),
                  onTap: context.pop,
                ),
              ),
            ),
            floating: false,
            pinned: true,
            snap: false,
            expandedHeight: 256.h,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () => controller.handleChangeCover(context),
                child: Hero(
                  tag: "mediaOrderDetail_$id",
                  child:
                      tempCover != null ||
                          (randomCover != null && randomCover.isNotEmpty) ||
                          cover.isNotEmpty
                      ? ExtendedImage.memory(
                          tempCover ?? randomCover ?? cover,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        )
                      : ExtendedImage.asset(
                          'assets/images/no_cover.png',
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            sliver: MultiSliver(
              children: [
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    child: Row(
                      children: [
                        Material(
                          borderRadius: BorderRadius.all(Radius.circular(6.r)),
                          clipBehavior: Clip.antiAlias,
                          type: MaterialType.transparency,
                          child: Ink(
                            child: InkWell(
                              onTap: controller.handlePlayAll,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
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
                                          fontSize: 22.sp,
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
                                          "(${mediaList.length})",
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
                      itemCount: mediaList.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16.h),
                      itemBuilder: (context, index) => controller.buildItem(
                        context,
                        index,
                        mediaList[index],
                        mediaItem,
                        paddingBottom,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
