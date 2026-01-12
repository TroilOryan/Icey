import 'dart:math';
import 'dart:ui';

import 'package:IceyPlayer/components/persistent_header/persistent_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:IceyPlayer/components/round_icon_button/round_icon_button.dart';
import 'package:go_router/go_router.dart';
import 'package:sliver_tools/sliver_tools.dart';

class PageWrapper extends StatelessWidget {
  final String title;
  final Widget body;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const PageWrapper({
    super.key,
    required this.title,
    required this.body,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final paddingTop = MediaQuery.of(context).padding.top,
        paddingBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          MultiSliver(
            children: [
              SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: PersistentHeaderBuilder(
                  min: kToolbarHeight + paddingTop,
                  max: 150.h,
                  builder: (ctx, offset) => ClipRect(
                    clipBehavior: Clip.antiAlias,
                    child: BackdropFilter(
                      enabled: offset > 20.h,
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0, paddingTop, 6.w, 0),
                        alignment: Alignment.centerLeft,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 36.sp,
                                margin: EdgeInsets.fromLTRB(24.w, 4.h, 0, 0),
                                child: RoundIconButton(
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
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              body is MultiSliver
                  ? SliverPadding(
                      padding:
                          padding ??
                          EdgeInsets.fromLTRB(
                            16.w,
                            12.h,
                            16.w,
                            paddingBottom + 12.h,
                          ),
                      sliver: body,
                    )
                  : SliverPadding(
                      padding:
                          padding ??
                          EdgeInsets.fromLTRB(
                            16.w,
                            12.h,
                            16.w,
                            paddingBottom + 12.h,
                          ),
                      sliver: SliverToBoxAdapter(child: body),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
