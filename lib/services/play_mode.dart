import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';

/// 播放模式
enum PlayMode {
  singleLoop(
    value: 1,
    name: "单曲循环",
    icon: SFIcons.sf_repeat_1,
  ),
  random(
    value: 2,
    name: "随机",
    icon: SFIcons.sf_shuffle,
  ),
  listLoop(
    value: 3,
    name: "列表循环",
    icon: SFIcons.sf_repeat,
  ),
  listOrder(
    value: 4,
    name: "顺序播放",
    icon: SFIcons.sf_list_number,
  );

  final int value;
  final String name;
  final IconData icon;

  const PlayMode({required this.value, required this.name, required this.icon});

  static PlayMode getByValue(int value) {
    return values.firstWhere((element) => element.value == value);
  }
}
