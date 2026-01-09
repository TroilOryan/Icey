import 'dart:math';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';

class MultiSwitch extends StatelessWidget {
  const MultiSwitch({super.key});

  Widget iconDataByValue(int? value) => switch (value) {
    0 => Text("圆形"),
    1 => Text("方形"),
    2 => Text("不规则"),
    _ => Text("沉浸"),
  };

  Widget rollingIconBuilder(int? value, bool foreground) {
    return iconDataByValue(value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedToggleSwitch<int>.rolling(
      current: 1,
      indicatorIconScale: sqrt2,
      values: const [0, 1, 2, 3],
      height: 26,
      padding: EdgeInsets.all(4),
      indicatorSize: Size.square(26 * 2 - 2 * 2),
      onChanged: (i) {
        // setState(() => value = i);
        return Future<dynamic>.delayed(const Duration(seconds: 3));
      },
      iconBuilder: rollingIconBuilder,
    );
  }
}
