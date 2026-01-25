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
  final VoidCallback onPlayRandom;
  final VoidCallback onOpenSortMenu;

  const HeaderAppBar({
    super.key,
    required this.onPlayRandom,
    required this.onOpenSortMenu,
  });

  void handleMenuSelected(int value, BuildContext context) {
    if (value == 1) {
      onOpenSortMenu();
    } else if (value == 2) {
      context.push("/settings");
    }
  }

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
                    "媒体库",
                    style: textTheme.titleLarge!.copyWith(
                      fontSize:
                          textTheme.titleLarge!.fontSize! *
                          max((1.5 - offset / 200), 0.8),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: SFIcon(SFIcons.sf_shuffle, fontSize: 20),
                        onPressed: onPlayRandom,
                      ),
                      IconButton(
                        icon: SFIcon(SFIcons.sf_list_bullet, fontSize: 20),
                        onPressed: onOpenSortMenu,
                      ),
                      // PopupMenuButton(
                      //   clipBehavior: Clip.antiAlias,
                      //   onSelected: (value) =>
                      //       handleMenuSelected(value, context),
                      //   itemBuilder: (context) => menu,
                      //   icon: SFIcon(SFIcons.sf_plus, fontSize: 22),
                      // ),
                    ],
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
