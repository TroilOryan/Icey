import 'package:IceyPlayer/constants/strings.dart';
import 'package:IceyPlayer/src/rust/api/utils.dart';
import 'package:animated_gradient_background/animated_gradient_background.dart';
import 'package:IceyPlayer/components/button/button.dart';
import 'package:flutter/material.dart';
import 'package:IceyPlayer/components/media_default_cover/media_default_cover.dart';

const size = 256.0;

class MediaEmpty extends StatelessWidget {
  final VoidCallback onScan;

  const MediaEmpty({super.key, required this.onScan});

  Widget _buildCover({required double size, required double paddingTop}) =>
      Positioned(
        right: -size / 2,
        top: paddingTop + 24,
        child: MediaDefaultCover(
          size: Size(size, size),
          isDarkMode: true,
          borderRadius: BorderRadius.all(Radius.circular(300)),
        ),
      );

  Widget _buildBody({required ThemeData theme, required double paddingBottom}) {
    final titleStyle = theme.textTheme.titleLarge!.copyWith(fontSize: 48);

    return Positioned(
      left: 48,
      bottom: paddingBottom + 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("哈喽", style: titleStyle),
          Text("欢迎来到", style: titleStyle),
          Text(Strings.appName, style: titleStyle),
        ],
      ),
    );
  }

  Widget _buildAction({
    required ThemeData theme,
    required double paddingBottom,
  }) {
    final bodyStyle = theme.textTheme.bodyLarge;

    return Positioned(
      right: 48,
      bottom: paddingBottom + 24,
      child: Row(
        spacing: 16,
        children: [
          Text("添加音乐以开始", style: bodyStyle),
          Button(onPressed: onScan, child: Text("扫描")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final paddingTop = MediaQuery.of(context).padding.top,
        paddingBottom = MediaQuery.of(context).padding.bottom;

    return AnimatedGradientBackground(
      duration: const Duration(seconds: 6),
      colors: [theme.scaffoldBackgroundColor, theme.cardTheme.color!],
      child: Stack(
        children: [
          _buildCover(size: size, paddingTop: paddingTop),
          _buildBody(theme: theme, paddingBottom: paddingBottom),
          _buildAction(theme: theme, paddingBottom: paddingBottom),
        ],
      ),
    );
  }
}
