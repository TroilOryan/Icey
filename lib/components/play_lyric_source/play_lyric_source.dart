import 'package:IceyPlayer/models/lyric/lyric.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

enum LyricSource {
  file(value: 'file', name: "文件"),
  tag(value: 'tag', name: "标签"),
  none(value: 'none', name: "无");

  final String value;
  final String name;

  const LyricSource({required this.value, required this.name});

  static LyricSource getByValue(String value) {
    return values.firstWhere((element) => element.value == value);
  }
}

class PlayLyricSource extends StatelessWidget {
  const PlayLyricSource({super.key});

  @override
  Widget build(BuildContext context) {
    final appThemeExtension = AppThemeExtension.of(context);

    return Container(
      width: 22,
      height: 22,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: appThemeExtension.primary.withAlpha(20),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
        color: appThemeExtension.secondaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      child: Center(
        child: Text(
          lyricManager.lyricSource.value.name.substring(0, 1),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: appThemeExtension.secondary),
        ),
      ),
    );
  }
}
