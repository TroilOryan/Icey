import 'package:IceyPlayer/pages/media_library/az_list_cursor/az_list_cursor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keframe/keframe.dart';

class MediaListCursor extends StatelessWidget {
  final bool offstage;
  final AzListCursorInfoModel? cursorInfo;
  final double indexBarWidth;

  const MediaListCursor({
    super.key,
    required this.offstage,
    required this.cursorInfo,
    required this.indexBarWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (offstage || cursorInfo == null) {
      return SizedBox.shrink();
    }

    return Builder(
      builder: (context) {
        Widget resultWidget = Container();

        double top = 0, right = indexBarWidth + 16.w;

        double titleSize = 80.h;

        top = cursorInfo!.offset.dy + 190.h - titleSize * 0.5;

        resultWidget = AzListCursor(size: titleSize, title: cursorInfo!.title);

        resultWidget = Positioned(
          top: top,
          right: right,
          child: FrameSeparateWidget(child: resultWidget),
        );

        return resultWidget;
      },
    );
  }
}
