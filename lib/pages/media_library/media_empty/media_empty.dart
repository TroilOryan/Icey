import 'package:animated_gradient_background/animated_gradient_background.dart';
import 'package:IceyPlayer/components/button/button.dart';
import 'package:flutter/material.dart';
import 'package:IceyPlayer/components/media_default_cover/media_default_cover.dart';

class MediaEmpty extends StatelessWidget {
  final VoidCallback onScan;

  const MediaEmpty({super.key, required this.onScan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final deviceWidth = MediaQuery.of(context).size.width;

    final titleStyle = Theme.of(
      context,
    ).textTheme.titleLarge!.copyWith(fontSize: 48);

    final bodyStyle = Theme.of(context).textTheme.bodyLarge;

    final paddingTop = MediaQuery.of(context).padding.top,
        paddingBottom = MediaQuery.of(context).padding.bottom;

    final size = deviceWidth;

    return AnimatedGradientBackground(
      duration: const Duration(seconds: 6),
      colors: [theme.scaffoldBackgroundColor, theme.cardTheme.color!],
      child: Stack(
        children: [
          Positioned(
            right: -size / 2,
            top: paddingTop + 24,
            child: MediaDefaultCover(
              size: Size(size, size),
              isDarkMode: true,
              borderRadius: BorderRadius.all(Radius.circular(300)),
            ),
          ),
          Positioned(
            left: 48,
            bottom: paddingBottom + 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("哈喽", style: titleStyle),
                Text("欢迎来到", style: titleStyle),
                Text("Icey Player", style: titleStyle),
              ],
            ),
          ),
          Positioned(
            right: 48,
            bottom: paddingBottom + 24,
            child: Row(
              spacing: 16,
              children: [
                Text("添加音乐以开始", style: bodyStyle),
                Button(onPressed: onScan, child: Text("扫描")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
