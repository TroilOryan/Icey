import 'dart:math';
import 'dart:ui';

import 'package:IceyPlayer/components/round_icon_button/round_icon_button.dart';
import 'package:IceyPlayer/helpers/platform.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'persistent_header.dart';

class HeaderAppBarAction {
  final IconData icon;
  final VoidCallback onTap;

  const HeaderAppBarAction({required this.icon, required this.onTap});
}

class HeaderAppBar extends StatelessWidget {
  final String title;
  final bool centerTitle;
  final bool ghost;
  final List<HeaderAppBarAction>? action;
  final VoidCallback? onTap;

  const HeaderAppBar({
    super.key,
    required this.title,
    this.centerTitle = false,
    this.ghost = false,
    this.action,
    this.onTap,
  });

  Widget _buildTitle({required ThemeData theme, required double offset}) {
    final textTheme = theme.textTheme;

    return Text(
      title,
      style: textTheme.titleLarge!.copyWith(
        fontSize:
            textTheme.titleLarge!.fontSize! * max((1.5 - offset / 200), 0.8),
      ),
    );
  }

  Widget _buildAction({required ThemeData theme}) {
    if (action == null || action!.isEmpty) {
      return SizedBox.shrink();
    }

    return Row(
      children: action!
          .map(
            (e) => IconButton(onPressed: e.onTap, icon: Icon(e.icon, size: 20)),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final paddingTop = MediaQuery.of(context).viewPadding.top;

    return SliverPersistentHeader(
      pinned: !PlatformHelper.isDesktop,
      floating: false,
      delegate: PersistentHeaderBuilder(
        min: kToolbarHeight + paddingTop,
        max: 150,
        builder: (ctx, offset) => ClipRect(
          clipBehavior: Clip.antiAlias,
          child: BackdropFilter(
            enabled: !ghost && offset > 20,
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Container(
                color: ghost
                    ? null
                    : theme.scaffoldBackgroundColor.withAlpha(200),
                alignment: Alignment.centerLeft,
                padding: centerTitle
                    ? EdgeInsets.only(top: paddingTop)
                    : EdgeInsets.fromLTRB(24, paddingTop, 6, 0),
                child: centerTitle
                    ? Stack(
                        children: [
                          if (context.canPop())
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 36,
                                margin: EdgeInsets.fromLTRB(24, 4, 0, 0),
                                child: RoundIconButton(
                                  ghost: false,
                                  icon: const Icon(Icons.arrow_back),
                                  onTap: context.pop,
                                ),
                              ),
                            ),
                          Center(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    fontSize:
                                        Theme.of(
                                          context,
                                        ).textTheme.titleLarge!.fontSize! *
                                        max((1.5 - offset / 200), 0.8),
                                  ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      )
                    : Row(
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
