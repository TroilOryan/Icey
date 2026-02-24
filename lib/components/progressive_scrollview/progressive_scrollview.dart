import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';
import '../round_icon_button/round_icon_button.dart';

/// AppBar 动作项
class HeaderAppBarAction {
  final IconData icon;
  final VoidCallback onTap;
  const HeaderAppBarAction({
    required this.icon,
    required this.onTap,
  });
}

/// 滚动控制器 - 每个组件实例独立
class ProgressiveScrollViewController {
  final Signal<double> offset = signal(0.0);

  bool handleNotification(Object? notification) {
    if (notification is ScrollUpdateNotification) {
      offset.value = notification.metrics.pixels;
      return false; // 不阻止通知继续传播
    }
    return false;
  }

  void dispose() {
    offset.dispose();
  }
}

/// 渐进式滚动视图组件
class ProgressiveScrollview extends StatefulWidget {
  final String title;
  final bool centerTitle;
  final CustomScrollView? child;
  final Widget Function(double)? builder;
  final List<HeaderAppBarAction>? action;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final ProgressiveScrollViewController? controller;

  const ProgressiveScrollview({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.child,
    this.builder,
    this.action,
    this.backgroundColor,
    this.onTap,
    this.controller,
  });

  @override
  State<ProgressiveScrollview> createState() => _ProgressiveScrollviewState();
}

class _ProgressiveScrollviewState extends State<ProgressiveScrollview> {
  late final ProgressiveScrollViewController _controller;

  // Computed 在 initState 中创建，避免每次 build 都创建新的
  late final Computed<double> _appbarHeight;
  late final Computed<double> _fontSize;

  @override
  void initState() {
    super.initState();

    // 使用传入的 controller 或创建新的
    _controller = widget.controller ?? ProgressiveScrollViewController();

    // 在 initState 中创建 computed，避免内存泄漏
    _appbarHeight = computed(() {
      final paddingTop = MediaQuery.of(context).viewPadding.top;
      final offset = _controller.offset.value;
      return max(150 - offset, kToolbarHeight + paddingTop);
    });

    _fontSize = computed(() {
      final titleLargeFontSize = Theme.of(context).textTheme.titleLarge?.fontSize ?? 20;
      final offset = _controller.offset.value;
      return titleLargeFontSize * max((1.5 - offset / 200), 0.8);
    });
  }

  @override
  void didUpdateWidget(ProgressiveScrollview oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果 controller 发生变化，需要处理旧的 controller
    if (widget.controller != oldWidget.controller && widget.controller != null) {
      // 清理旧的 computed（如果需要）
      // 注意：这里需要根据实际情况处理
    }
  }

  @override
  void dispose() {
    // 只在组件自己创建 controller 时才释放
    if (widget.controller == null) {
      _controller.dispose();
    }
    // 释放 computed
    _appbarHeight.dispose();
    _fontSize.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offset = _controller.offset.watch(context);
    final paddingTop = MediaQuery.of(context).viewPadding.top;

    return Stack(
      children: [
        _buildBody(theme),
        _buildAppBar(theme, paddingTop),
      ],
    );
  }

  /// 构建主体内容
  Widget _buildBody(ThemeData theme) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SoftEdgeBlur(
        edges: [
          EdgeBlur(
            type: EdgeType.topEdge,
            size: 125,
            sigma: 12,
            controlPoints: [
              ControlPoint(position: 0.5, type: ControlPointType.visible),
              ControlPoint(position: 1, type: ControlPointType.transparent),
            ],
          ),
        ],
        child: NotificationListener(
          onNotification: _controller.handleNotification,
          child: widget.child ??
              Builder(
                builder: (context) => widget.builder != null
                    ? widget.builder!(_appbarHeight())
                    : const SizedBox(),
              ),
        ),
      ),
    );
  }

  /// 构建 AppBar
  Widget _buildAppBar(ThemeData theme, double paddingTop) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Container(
        padding: widget.centerTitle
            ? EdgeInsets.only(top: paddingTop)
            : EdgeInsets.fromLTRB(24, paddingTop, 6, 0),
        height: _appbarHeight(),
        child: widget.centerTitle
            ? _buildCenterTitleAppBar(theme, paddingTop)
            : _buildLeftTitleAppBar(theme),
      ),
    );
  }

  /// 居中标题的 AppBar
  Widget _buildCenterTitleAppBar(ThemeData theme, double paddingTop) {
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
          child: _buildTitle(theme: theme, fontSize: _fontSize()),
        ),
      ],
    );
  }

  /// 左侧标题的 AppBar
  Widget _buildLeftTitleAppBar(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildTitle(theme: theme, fontSize: _fontSize())),
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
          .map((e) => IconButton(
        onPressed: e.onTap,
        icon: Icon(e.icon, size: 20),
        tooltip: 'Action', // 添加 tooltip 提升可访问性
      ))
          .toList(),
    );
  }
}
