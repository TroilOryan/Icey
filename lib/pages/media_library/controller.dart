import 'dart:math';

import 'package:IceyPlayer/event_bus/event_bus.dart';
import 'package:IceyPlayer/pages/media_library/media_locator/media_locator.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:go_router/go_router.dart';
import 'package:IceyPlayer/helpers/media_scanner/media_scanner.dart';
import 'package:IceyPlayer/helpers/media_scanner/media_sort.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/pages/home/controller.dart';
import 'package:IceyPlayer/pages/media_library/media_empty/media_empty.dart';
import 'package:IceyPlayer/pages/media_library/media_list/media_list.dart';
import 'package:flutter/material.dart';
import 'package:pinyin/pinyin.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'az_list_cursor/az_list_cursor.dart';
import 'az_list_cursor/media_list_cursor.dart';
import 'az_list_index_bar/media_list_index_bar.dart';
import 'header_app_bar/header_app_bar.dart';

part 'page.dart';

part 'state.dart';

class MediaLibraryController {
  final indexBarWidth = 16.0;

  final state = MediaLibraryState();

  final FocusNode focusNode = FocusNode();

  void handleNavToSearch(BuildContext context) {
    context.push("/search");

    focusNode.unfocus();
  }

  void handleSelectionUpdate(int index, Offset offset) {
    final sortType = settingsManager.sortType.value;

    state.cursorInfo.value = AzListCursorInfoModel(
      title: symbols[index],
      offset: offset,
    );

    final mediaIndex = mediaManager.mediaList.value.indexWhere((media) {
      final firstLetter = PinyinHelper.getPinyinE(
        (sortType == MediaSort.title ? media.title : media.artist) ?? "",
      );

      return firstLetter.toUpperCase().substring(0, 1) == symbols[index];
    });

    if (mediaIndex != -1) {
      homeController.observerController.jumpTo(
        index: mediaIndex,
        offset: (_) => 150,
      );
    }
  }

  void handleSelectionEnd() {
    state.cursorInfo.value = null;
  }

  void handleOpenSortMenu() {
    eventBus.fire(OpenSortMenu());
  }

  void _listenFocusNode() {
    state.focused.value = focusNode.hasFocus;
  }

  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      focusNode.addListener(_listenFocusNode);
    });
  }

  void onDispose() {
    focusNode.removeListener(_listenFocusNode);
  }
}
