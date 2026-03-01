import 'dart:math';

import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

import '../round_icon_button/round_icon_button.dart';

class HeaderAppBarAction {
  final IconData icon;
  final VoidCallback onTap;

  const HeaderAppBarAction({required this.icon, required this.onTap});
}

class ProgressiveScrollview extends StatelessWidget {
  final String title;
  final bool centerTitle;
  final Function(double) builder;
  final List<HeaderAppBarAction>? action;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const ProgressiveScrollview({
    super.key,
    required this.title,
    this.centerTitle = true,
    required this.builder,
    this.action,
    this.backgroundColor,
    this.onTap,
  });

  /// 构建主体内容
  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    double appbarHeight,
  ) {
    final listBg = settingsManager.listBg.watch(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SoftEdgeBlur(
        edges: [
          EdgeBlur(
            type: EdgeType.topEdge,
            size: 100,
            sigma: 12,
            tintColor: listBg.isEmpty
                ? theme.floatingActionButtonTheme.backgroundColor
                : null,
            controlPoints: [
              ControlPoint(position: 0.5, type: ControlPointType.visible),
              ControlPoint(position: 1, type: ControlPointType.transparent),
            ],
          ),
        ],
        child: Builder(builder: (context) => builder(appbarHeight)),
      ),
    );
  }

  /// 构建 AppBar
  Widget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    double paddingTop,
    double appbarHeight,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: centerTitle
            ? EdgeInsets.only(top: paddingTop)
            : EdgeInsets.fromLTRB(24, paddingTop, 6, 0),
        height: appbarHeight,
        child: centerTitle
            ? _buildCenterTitleAppBar(context, theme, paddingTop)
            : _buildLeftTitleAppBar(theme),
      ),
    );
  }

  /// 居中标题的 AppBar
  Widget _buildCenterTitleAppBar(
    BuildContext context,
    ThemeData theme,
    double paddingTop,
  ) {
    return Stack(
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
        Center(child: _buildTitle(theme: theme)),
      ],
    );
  }

  /// 左侧标题的 AppBar
  Widget _buildLeftTitleAppBar(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildTitle(theme: theme)),
        _buildAction(theme),
      ],
    );
  }

  /// 构建标题
  Widget _buildTitle({required ThemeData theme}) {
    final textTheme = theme.textTheme;
    return Text(title, style: textTheme.titleLarge);
  }

  /// 构建操作按钮
  Widget _buildAction(ThemeData theme) {
    if (action == null || action!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: action!
          .map(
            (e) => IconButton(
              onPressed: e.onTap,
              icon: Icon(e.icon, size: 20),
              tooltip: 'Action', // 添加 tooltip 提升可访问性
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paddingTop = MediaQuery.of(context).viewPadding.top;
    final double appbarHeight = max(75, kToolbarHeight + paddingTop);

    return Stack(
      children: [
        _buildBody(context, theme, appbarHeight),
        _buildAppBar(context, theme, paddingTop, appbarHeight),
      ],
    );
  }
}
