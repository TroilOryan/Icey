import 'dart:math';
import 'dart:ui';

import 'package:IceyPlayer/components/persistent_header/persistent_header.dart';
import 'package:IceyPlayer/helpers/platform.dart';
import 'package:IceyPlayer/helpers/toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:go_router/go_router.dart';

late StatefulNavigationShell nav;

class HeaderAppBar extends StatelessWidget {
  final VoidCallback onPlayRandom;
  final VoidCallback onOpenSortMenu;
  final VoidCallback onTap;

  const HeaderAppBar({
    super.key,
    required this.onPlayRandom,
    required this.onOpenSortMenu,
    required this.onTap,
  });

  void handleMenuSelected(int value, BuildContext context) {
    if (value == 1) {
      onOpenSortMenu();
    } else if (value == 2) {
      context.push("/settings");
    }
  }

  Widget _buildTitle({required ThemeData theme, required double offset}) {
    final textTheme = theme.textTheme;

    return Text(
      "媒体库",
      style: textTheme.titleLarge!.copyWith(
        fontSize:
            textTheme.titleLarge!.fontSize! * max((1.5 - offset / 200), 0.8),
      ),
    );
  }

  Widget _buildAction({required ThemeData theme}) {
    return Row(
      children: [
        IconButton(
          icon: SFIcon(SFIcons.sf_shuffle, fontSize: 20),
          onPressed: onPlayRandom,
        ),
        IconButton(
          icon: SFIcon(SFIcons.sf_list_bullet, fontSize: 20),
          onPressed: onOpenSortMenu,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final paddingTop = MediaQuery.of(context).padding.top;

    return SliverPersistentHeader(
      pinned: !PlatformHelper.isDesktop,
      floating: false,
      delegate: PersistentHeaderBuilder(
        min: kToolbarHeight + paddingTop,
        max: 150,
        builder: (ctx, offset) => ClipRect(
          clipBehavior: Clip.antiAlias,
          child: BackdropFilter(
            enabled: offset > 20,
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.fromLTRB(24, paddingTop, 6, 0),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTitle(theme: theme, offset: offset),
                    _buildAction(theme: theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
