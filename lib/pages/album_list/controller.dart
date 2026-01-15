import 'dart:typed_data';

import 'package:audio_query/types/artwork_type.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:IceyPlayer/components/media_cover/media_cover.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/pages/album_list/state.dart';
import 'package:IceyPlayer/pages/home/controller.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:signals/signals_flutter.dart';

part 'page.dart';

class AlbumListController {
  final state = AlbumListState();

  void handleQueried(Uint8List v, BigInt id) {
    final coverList = List.from(state.coverList.value);

    coverList.add(CoverMap(id: id, cover: v));

    state.coverList.value = List.unmodifiable(coverList);
  }

  void onInit() {

  }
}
