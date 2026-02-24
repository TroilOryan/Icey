import 'package:IceyPlayer/components/progressive_scrollview/progressive_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

class PageWrapper extends StatelessWidget {
  final String title;
  final Widget body;
  final bool ghost;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const PageWrapper({
    super.key,
    required this.title,
    required this.body,
    this.ghost = false,
    this.backgroundColor,
    this.padding,
  });

  Widget _buildBody({
    required BuildContext context,
    required double appbarHeight,
  }) {
    final paddingBottom = MediaQuery.of(context).padding.bottom;

    if (body is MultiSliver) {
      return SliverPadding(
        padding:
            padding ??
            EdgeInsets.fromLTRB(16, 12 + appbarHeight, 16, paddingBottom + 12),
        sliver: body,
      );
    }

    return SliverPadding(
      padding:
          padding ??
          EdgeInsets.fromLTRB(16, 12 + appbarHeight, 16, paddingBottom + 12),
      sliver: SliverToBoxAdapter(child: body),
    );
  }

  void listenScroll() {}

  void onInit() {}

  void onDispose() {}

  @override
  Widget build(BuildContext context) {
    return ProgressiveScrollview(
      title: title,
      builder: (appbarHeight) => CustomScrollView(
        slivers: [_buildBody(context: context, appbarHeight: appbarHeight)],
      ),
    );
  }
}
