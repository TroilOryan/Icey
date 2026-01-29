import 'package:IceyPlayer/entities/media.dart';
import 'package:IceyPlayer/models/media/media.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audio_query/types/artwork_type.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:go_router/go_router.dart';
import 'package:IceyPlayer/components/label_value/label_value.dart';
import 'package:IceyPlayer/components/media_cover/media_cover.dart';
import 'package:IceyPlayer/components/media_list_tile/media_list_tile.dart';
import 'package:IceyPlayer/components/page_wrapper/page_wrapper.dart';
import 'package:IceyPlayer/helpers/common.dart';
import 'package:IceyPlayer/pages/home/controller.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

part 'page.dart';

class AlbumListDetailController {
  void handlePlayAll(List<MediaEntity> mediaList) {
    if (mediaList.isEmpty) return;

    mediaManager.updateQueue(mediaList.map(MediaEntity.toMediaItem).toList());

    mediaManager.skipToQueueItem(0);
  }
}
