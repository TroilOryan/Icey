import 'dart:math';
import 'dart:ui';

import 'package:IceyPlayer/components/persistent_header/persistent_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:go_router/go_router.dart';

const menu = [
  PopupMenuItem(value: 1, child: Text("媒体排序")),
  PopupMenuItem(value: 2, child: Text("设置中心")),
];

late StatefulNavigationShell nav;

class HeaderAppBar extends StatelessWidget {

  const HeaderAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;

    final textTheme = Theme.of(context).textTheme;

    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: PersistentHeaderBuilder(
        min: kToolbarHeight + paddingTop,
        max: 150,
        builder: (ctx, offset) => ClipRect(
          clipBehavior: Clip.antiAlias,
          child: BackdropFilter(
            enabled: offset > 20,
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: EdgeInsets.fromLTRB(24, paddingTop, 6, 0),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "艺术家",
                    style: textTheme.titleLarge!.copyWith(
                      fontSize:
                          textTheme.titleLarge!.fontSize! *
                          max((1.5 - offset / 200), 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
