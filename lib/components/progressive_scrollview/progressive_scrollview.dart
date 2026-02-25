import 'dart:math';

import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keframe/keframe.dart';
import 'package:signals/signals_flutter.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

import '../round_icon_button/round_icon_button.dart';

class HeaderAppBarAction {
  final IconData icon;
  final VoidCallback onTap;

  const HeaderAppBarAction({required this.icon, required this.onTap});
}

class ProgressiveScrollViewController {
  final offset = signal(0.0);

  bool handleNotification(Object? notification) {
    if (notification is ScrollUpdateNotification) {
      final double scrollOffset = notification.metrics.pixels;

      offset.value = scrollOffset;
    }

    return false;
  }
}

class ProgressiveScrollview extends StatefulWidget {
  final String title;
  final bool centerTitle;
  final Function(double)? builder;
  final List<HeaderAppBarAction>? action;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const ProgressiveScrollview({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.builder,
    this.action,
    this.backgroundColor,
    this.onTap,
  });

  @override
  State<ProgressiveScrollview> createState() => _ProgressiveScrollviewState();
}

class _ProgressiveScrollviewState extends State<ProgressiveScrollview> {
  final controller = ProgressiveScrollViewController();

  /// 构建主体内容
  Widget _buildBody(ThemeData theme, double appbarHeight) {
    final listBg = settingsManager.listBg.watch(context);

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SoftEdgeBlur(
        edges: [
          EdgeBlur(
            type: EdgeType.topEdge,
            size: 125,
            sigma: 12,
            tintColor: listBg.isEmpty ? theme.cardTheme.color : null,
            controlPoints: [
              ControlPoint(position: 0.5, type: ControlPointType.visible),
              ControlPoint(position: 1, type: ControlPointType.transparent),
            ],
          ),
        ],
        child: NotificationListener(
          onNotification: controller.handleNotification,
          child: Builder(
            builder: (context) => widget.builder != null
                ? widget.builder!(appbarHeight)
                : const SizedBox(),
          ),
        ),
      ),
    );
  }

  /// 构建 AppBar
  Widget _buildAppBar(
    ThemeData theme,
    double paddingTop,
    double appbarHeight,
    double fontSize,
  ) {
    return FrameSeparateWidget(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          padding: widget.centerTitle
              ? EdgeInsets.only(top: paddingTop)
              : EdgeInsets.fromLTRB(24, paddingTop, 6, 0),
          height: appbarHeight,
          child: widget.centerTitle
              ? _buildCenterTitleAppBar(theme, paddingTop, fontSize)
              : _buildLeftTitleAppBar(theme, fontSize),
        ),
      ),
    );
  }

  /// 居中标题的 AppBar
  Widget _buildCenterTitleAppBar(
    ThemeData theme,
    double paddingTop,
    double fontSize,
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
        Center(
          child: _buildTitle(theme: theme, fontSize: fontSize),
        ),
      ],
    );
  }

  /// 左侧标题的 AppBar
  Widget _buildLeftTitleAppBar(ThemeData theme, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildTitle(theme: theme, fontSize: fontSize),
        ),
        _buildAction(theme),
      ],
    );
  }

  /// 构建标题
  Widget _buildTitle({required ThemeData theme, required double fontSize}) {
    final textTheme = theme.textTheme;
    return Text(
      widget.title,
      style: textTheme.titleLarge?.copyWith(fontSize: fontSize),
    );
  }

  /// 构建操作按钮
  Widget _buildAction(ThemeData theme) {
    if (widget.action == null || widget.action!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.action!
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
    final offset = controller.offset.watch(context);
    final paddingTop = MediaQuery.of(context).viewPadding.top;
    final appbarHeight = computed(
      () => max(150 - offset, kToolbarHeight + paddingTop),
    );

    final fontSize = computed(
      () =>
          Theme.of(context).textTheme.titleLarge!.fontSize! *
          max((1.5 - offset / 200), 0.8),
    );

    return Stack(
      children: [
        _buildBody(theme, appbarHeight()),
        _buildAppBar(theme, paddingTop, appbarHeight(), fontSize()),
      ],
    );
  }
}
