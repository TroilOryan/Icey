import 'package:IceyPlayer/components/header_app_bar/header_app_bar.dart';
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

  Widget _buildBody({required BuildContext context}) {
    final paddingBottom = MediaQuery.of(context).padding.bottom;

    if (body is MultiSliver) {
      return SliverPadding(
        padding: padding ?? EdgeInsets.fromLTRB(16, 12, 16, paddingBottom + 12),
        sliver: body,
      );
    }

    return SliverPadding(
      padding: padding ?? EdgeInsets.fromLTRB(16, 12, 16, paddingBottom + 12),
      sliver: SliverToBoxAdapter(child: body),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          MultiSliver(
            children: [
              HeaderAppBar(title: title, ghost: ghost, centerTitle: true),
              _buildBody(context: context),
            ],
          ),
        ],
      ),
    );
  }
}
