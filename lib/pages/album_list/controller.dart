import 'dart:typed_data';

import 'package:IceyPlayer/components/bottom_sheet/bottom_sheet.dart';
import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/constants/cache_key.dart';
import 'package:IceyPlayer/components/progressive_scrollview/progressive_scrollview.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:IceyPlayer/helpers/platform.dart';
import 'package:audio_query/types/artwork_type.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:IceyPlayer/components/media_cover/media_cover.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/pages/home/controller.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:signals/signals_flutter.dart';

part 'page.dart';

part 'state.dart';

class AlbumListController {
  final state = AlbumListState();

  void handleQueried(Uint8List v, String id) {
    // 延迟到帧结束后更新，避免在 Hero 动画进行中触发列表重建
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final coverList = List.from(state.coverList.value);
      coverList.add(CoverMap(id: id, cover: v));
      state.coverList.value = List.unmodifiable(coverList);
    });
  }

  void onInit() {}
}
