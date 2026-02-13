import 'dart:async';
import 'dart:math';

import 'package:IceyPlayer/components/sliding_up_panel/sliding_up_panel.dart';
import 'package:IceyPlayer/helpers/platform.dart';
import 'package:IceyPlayer/models/lyric/lyric.dart';
import 'package:IceyPlayer/pages/home/bottom_bar/bottom_bar.dart';
import 'package:IceyPlayer/pages/home/side_bar/side_bar.dart';
import 'package:IceyPlayer/pages/home/title_bar_action/title_bar_action.dart';
import 'package:IceyPlayer/pages/media_library/media_empty/media_empty.dart';
import 'package:audio_query/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_minimizer_plus/flutter_app_minimizer_plus.dart';
import 'package:IceyPlayer/components/bottom_sheet/bottom_sheet.dart';
import 'package:IceyPlayer/components/button/button.dart';
import 'package:IceyPlayer/components/media_list_tile/media_list_tile.dart';
import 'package:IceyPlayer/components/media_more_sheet/media_more_sheet.dart';
import 'package:IceyPlayer/components/play_bar/play_bar.dart';
import 'package:IceyPlayer/components/sheet_item/sheet_item.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/entities/media.dart';
import 'package:IceyPlayer/event_bus/event_bus.dart';
import 'package:IceyPlayer/helpers/media/media.dart';
import 'package:IceyPlayer/helpers/media_scanner/media_sort.dart';
import 'package:IceyPlayer/helpers/toast/toast.dart';
import 'package:IceyPlayer/helpers/update/update.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../main.dart';
import 'state.dart';

import 'package:path/path.dart' as path;

part 'page.dart';

class MenuData {
  final String label;

  final IconData icon;

  final IconData selectedIcon;

  const MenuData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

class HomeController {
  final state = HomeState();

  late final StatefulNavigationShell navigationShell;

  Timer? _scrollTimer;

  final _settingsBox = Boxes.settingsBox;

  final List<MenuData> menu = [
    MenuData(
      label: '媒体库',
      icon: FluentIcons.music_note_1_20_regular,
      selectedIcon: FluentIcons.music_note_1_20_filled,
    ),
    MenuData(
      label: '专辑',
      icon: FluentIcons.connected_16_regular,
      selectedIcon: FluentIcons.connected_16_filled,
    ),
    MenuData(
      label: '艺术家',
      icon: FluentIcons.person_head_hint_16_regular,
      selectedIcon: FluentIcons.person_head_hint_16_filled,
    ),
    MenuData(
      label: '设置',
      icon: FluentIcons.status_16_regular,
      selectedIcon: FluentIcons.status_16_filled,
    ),
  ];

  StreamController<List<AudioEntity>>? streamController;

  ScrollController? mediaScanListController = ScrollController();

  final ScrollController mediaListScrollController = ScrollController();

  final ScrollController albumListScrollController = ScrollController();

  final ScrollController artistListScrollController = ScrollController();

  Map<int, BuildContext> sliverContextMap = {};

  late final SliverObserverController observerController =
      SliverObserverController(controller: mediaListScrollController);

  late final StreamSubscription<ScanMediaStatus> _scanMediaStatusListener;

  late final StreamSubscription<OpenSortMenu> _openSortMenuListener;

  late final StreamSubscription<ScanMediaAdd> _scanMediaAddListener;

  late final EffectCleanup _panelOpenedListener;

  void handleLocate() {
    final index = mediaManager.mediaList.value.indexWhere(
      (item) => item.id.toString() == mediaManager.mediaItem.value?.id,
    );

    if (index != -1) {
      homeController.observerController.jumpTo(
        index: index,
        offset: (_) => 150,
      );
    }
  }

  void navToSearch(BuildContext context) {
    context.push("/search");
  }

  void handleGoBranch(int index) {
    navigationShell.goBranch(index);

    if (index == state.currentIndex.value) {
      state.sideBarOpened.value = !state.sideBarOpened.value;
    }

    state.currentIndex.value = index;
  }

  void handleMediaTap(MediaEntity media) {
    if (mediaManager.queue.value.indexWhere(
          (e) => e.id == media.id.toString(),
        ) ==
        -1) {
      mediaManager.updateQueue([MediaEntity.toMediaItem(media)]).then((_) {
        mediaManager.play(media.id);

        final mediaList = List<MediaEntity>.from(
          mediaManager.localMediaList.value,
        );

        mediaList.removeWhere((e) => e.id == media.id);

        mediaManager.addQueueItems(
          mediaList.map(MediaEntity.toMediaItem).toList(),
        );
      });
    } else {
      mediaManager.play(media.id);
    }
  }

  void handleMediaLongPress(MediaEntity media, BuildContext context) {
    scrollableBottomSheet(
      context: context,
      builder: (context) => [
        MediaListTile(
          media,
          obscure: false,
          showLike: true,
          onLike: MediaHelper.likeMedia,
        ),
        MediaMoreSheet.addToNextPlay(media),
        MediaMoreSheet.mediaArtist(context, media),
        MediaMoreSheet.mediaAlbum(context, media),
        MediaMoreSheet.openInMusicTagEditor(media),
        MediaMoreSheet.addToMediaOrder(context, media),
        MediaMoreSheet.mediaInfo(context, media),
        MediaMoreSheet.deleteMedia(media),
      ],
    );
  }

  void handleOpenSortMenu(BuildContext context) {
    bottomSheet(
      context: context,
      builder: (context, controller) {
        final sortType = settingsManager.sortType.watch(context);

        return Column(
          children: [
            Text("媒体排序", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Flexible(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: MediaSort.values.map((item) {
                  final active = sortType.value == item.value;

                  return SheetItem(
                    active: active,
                    label: item.name,
                    onTap: () => settingsManager.setSortType(item),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  void handlePopInvokedWithResult(bool didPop, Object? result) {
    if (didPop) return;

    if (state.panelOpened.value) {
      state.panelOpened.value = false;

      return;
    }

    FlutterAppMinimizerPlus.minimizeApp();
  }

  void handleBackTop() {
    late final ScrollController controller;

    if (state.currentIndex.value == 0) {
      controller = mediaListScrollController;
    } else if (state.currentIndex.value == 1) {
      controller = albumListScrollController;
    } else if (state.currentIndex.value == 2) {
      controller = artistListScrollController;
    }

    controller.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> handlePlayRandom() async {
    final Random random = Random();

    final int randomIndex = random.nextInt(mediaManager.queue.value.length);
    mediaManager.skipToQueueItem(randomIndex);
    mediaManager.play();
  }

  Future _listenScanMediaStatus(ScanMediaStatus e, BuildContext context) async {
    streamController ??= StreamController();
    mediaScanListController ??= ScrollController();

    if (e.isStart && e.silent != true) {
      DateTime start = DateTime.now();

      if (context.mounted) {
        bottomSheet(
          isDismissible: false,
          context: context,
          builder: (context, _) {
            final scanEndTime = state.scanEndTime.watch(context),
                scanEnded = state.scanEnded.watch(context);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("扫描音乐", style: Theme.of(context).textTheme.titleMedium),
                Text(
                  'Start: ${DateUtil.formatDate(start, format: DateFormats.full)}',
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: StreamBuilder(
                    stream: streamController?.stream,
                    builder: (context, snapshot) {
                      final queriedSongs = snapshot.data;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: SuperListView.builder(
                              controller: mediaScanListController,
                              itemCount: queriedSongs?.length ?? 0,
                              itemBuilder: (context, index) => Text(
                                queriedSongs?[index].data != null
                                    ? path.basename(queriedSongs![index].data)
                                    : "-",
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            scanEnded
                                ? "End: ${DateUtil.formatDate(scanEndTime, format: DateFormats.full)} 共${queriedSongs?.length ?? 0}首媒体"
                                : "",
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Button(
                  block: true,
                  disabled: !scanEnded,
                  onPressed: () async {
                    Navigator.of(context).pop();

                    final mediaList = MediaHelper.queryLocalMedia();

                    if (mediaManager.queue.value.isEmpty) {
                      mediaManager.updateQueue(
                        mediaList.map(MediaEntity.toMediaItem).toList(),
                      );
                    }

                    state.scanEnded.value = false;

                    Future.delayed(const Duration(milliseconds: 800)).then((_) {
                      streamController!.close();

                      streamController = null;

                      mediaScanListController?.dispose();

                      mediaScanListController = null;
                    });
                  },
                  child: const Text("确定"),
                ),
              ],
            );
          },
        );
      }
    } else if (!e.isStart && e.silent == true) {
      final mediaList = MediaHelper.queryLocalMedia();

      if (mediaManager.queue.value.isEmpty) {
        mediaManager.updateQueue(
          mediaList.map(MediaEntity.toMediaItem).toList(),
        );
      }

      showToast("媒体库更新成功");

      state.scanEnded.value = false;

      Future.delayed(const Duration(milliseconds: 800)).then((_) {
        streamController!.close();

        streamController = null;
      });
    } else {
      state.scanEndTime.value = DateTime.now();

      state.scanEnded.value = true;

      if (mediaScanListController?.position != null) {
        mediaScanListController!.jumpTo(
          mediaScanListController!.position.maxScrollExtent,
        );
      }
    }
  }

  void _listenScanMediaAdd(ScanMediaAdd e) {
    streamController?.add(e.audios);

    if (mediaScanListController!.hasClients != true) return;

    mediaScanListController!.jumpTo(
      mediaScanListController!.position.maxScrollExtent,
    );
  }

  void _listenMediaListScroll() {
    if (!settingsManager.scrollHidePlayBar.value) return;

    late final double currentOffset;

    if (state.currentIndex.value == 0) {
      currentOffset = mediaListScrollController.offset;
    } else if (state.currentIndex.value == 1) {
      currentOffset = albumListScrollController.offset;
    } else if (state.currentIndex.value == 2) {
      currentOffset = artistListScrollController.offset;
    }

    if (currentOffset != state.lastScrollOffset.value && currentOffset > 0) {
      final newDirection = currentOffset > state.lastScrollOffset.value
          ? ScrollDirection.forward
          : ScrollDirection.reverse;

      if (newDirection != state.scrollDirection.value) {
        state.scrollDirection.value = newDirection;

        if (newDirection == ScrollDirection.forward) {
          state.hidePlayBar.value = true;
        } else {
          state.hidePlayBar.value = false;
        }
      }
    }

    state.lastScrollOffset.value = currentOffset;

    Timer(const Duration(milliseconds: 100), () {
      final currentPosition = mediaListScrollController.offset;

      _scrollTimer?.cancel();

      if (state.hidePlayBar.value &&
          !mediaListScrollController.position.isScrollingNotifier.value &&
          mediaListScrollController.offset == currentPosition) {
        _scrollTimer = Timer(const Duration(milliseconds: 1000), () {
          state.hidePlayBar.value = false;
          state.scrollDirection.value = ScrollDirection.idle;

          _scrollTimer?.cancel();
        });
      }
    });
  }

  void handleOpenPanel(BuildContext context) {
    context.push("/play_screen").then((_) {
      state.panelOpened.value = false;
    });

    Future.delayed(const Duration(milliseconds: 600)).then((_) {
      state.panelOpened.value = true;
    });
  }

  void setStatusBarIconBrightness(bool isDark) {
    final brightness = isDark ? Brightness.light : Brightness.dark;

    final statusBarIconBrightness = appState.statusBarIconBrightness.value;

    if (statusBarIconBrightness == null ||
        statusBarIconBrightness != brightness) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      );

      appState.statusBarIconBrightness.value = brightness;
    }
  }

  void onInit(BuildContext context, StatefulNavigationShell navi) {
    navigationShell = navi;

    WidgetsBinding.instance.addPostFrameCallback((callback) {
      UpdateHelper.checkUpdate(context);

      final mediaItems = mediaManager.mediaList.value
          .map(MediaEntity.toMediaItem)
          .toList();

      mediaManager.loadPlaylist(mediaItems);

      _scanMediaStatusListener = eventBus.on<ScanMediaStatus>().listen(
        (e) => _listenScanMediaStatus(e, context),
      );

      _openSortMenuListener = eventBus.on<OpenSortMenu>().listen((e) {
        handleOpenSortMenu(context);
      });

      _scanMediaAddListener = eventBus.on<ScanMediaAdd>().listen(
        _listenScanMediaAdd,
      );

      mediaListScrollController.addListener(_listenMediaListScroll);

      albumListScrollController.addListener(_listenMediaListScroll);

      artistListScrollController.addListener(_listenMediaListScroll);

      _panelOpenedListener = effect(() {
        if (settingsManager.wakelock.value) {
          if (state.panelOpened.value) {
            WakelockPlus.enable();
          } else {
            WakelockPlus.disable();
          }
        }

        if (state.panelOpened.value) {
          setStatusBarIconBrightness(mediaManager.coverColor.value.isDark);
        } else {
          setStatusBarIconBrightness(
            MediaQuery.of(context).platformBrightness == Brightness.dark,
          );
        }
      });
    });
  }

  void onDispose() {
    mediaListScrollController.removeListener(_listenMediaListScroll);

    albumListScrollController.removeListener(_listenMediaListScroll);

    artistListScrollController.removeListener(_listenMediaListScroll);

    _scrollTimer?.cancel();

    _scanMediaAddListener.cancel();

    _scanMediaStatusListener.cancel();

    _openSortMenuListener.cancel();

    mediaScanListController?.dispose();

    _panelOpenedListener();

    lyricManager.dispose();
  }
}
