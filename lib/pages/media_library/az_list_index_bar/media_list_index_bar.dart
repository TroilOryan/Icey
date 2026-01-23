import 'package:IceyPlayer/entities/media.dart';
import 'package:flutter/material.dart';
import 'package:keframe/keframe.dart';

import 'az_list_index_bar.dart';

final indexBarContainerKey = GlobalKey();

final defaultAzList = List.generate(
  26,
  (index) => MediaAzListEntity(
    section: String.fromCharCode('A'.codeUnitAt(0) + index),
    media: [],
  ),
)..add(MediaAzListEntity(section: '#', media: []));

final symbols = defaultAzList.map((e) => e.section).toList();

class MediaAzListEntity {
  final String section;
  final List<MediaEntity> media;

  MediaAzListEntity({required this.section, required this.media});
}

class MediaListIndexBar extends StatelessWidget {
  final bool offstage;
  final double indexBarWidth;
  final void Function(int index, Offset cursorOffset)? onSelectionUpdate;
  final void Function()? onSelectionEnd;

  const MediaListIndexBar({
    super.key,
    required this.offstage,
    required this.indexBarWidth,
    required this.onSelectionUpdate,
    required this.onSelectionEnd,
  });

  @override
  Widget build(BuildContext context) {
    if (offstage) {
      return SizedBox.shrink();
    }

    return Positioned(
      top: 16,
      right: 0,
      child: FrameSeparateWidget(
        child: Container(
          padding: EdgeInsets.only(right: 6),
          key: indexBarContainerKey,
          width: indexBarWidth,
          alignment: Alignment.center,
          child: AzListIndexBar(
            parentKey: indexBarContainerKey,
            symbols: symbols,
            onSelectionUpdate: onSelectionUpdate,
            onSelectionEnd: onSelectionEnd,
          ),
        ),
      ),
    );
  }
}
