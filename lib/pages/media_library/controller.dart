import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:go_router/go_router.dart';
import 'package:IceyPlayer/components/high_material_wrapper/high_material_wrapper.dart';
import 'package:IceyPlayer/helpers/media_scanner/media_scanner.dart';
import 'package:IceyPlayer/helpers/media_scanner/media_sort.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/pages/home/controller.dart';
import 'package:IceyPlayer/pages/media_library/media_empty/media_empty.dart';
import 'package:IceyPlayer/pages/media_library/media_list/media_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:keframe/keframe.dart';
import 'package:pinyin/pinyin.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'az_list_cursor/az_list_cursor.dart';
import 'az_list_cursor/media_list_cursor.dart';
import 'az_list_index_bar/media_list_index_bar.dart';
import 'media_order/media_order.dart';
import 'media_search_bar/media_search_bar.dart';
import 'state.dart';

part 'page.dart';

class MediaLibraryController {
  final indexBarWidth = 16.w;

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
        offset: (_) => 150.h,
      );
    }
  }

  void handleSelectionEnd() {
    state.cursorInfo.value = null;
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
