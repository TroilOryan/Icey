// This switch is inspired by https://github.com/pedromassango/crazy-switch

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';

class IceySwitch extends StatelessWidget {
  final bool? value;
  final double height;
  final double borderWidth;
  final bool disabled;
  final Function(bool)? onChanged;

  const IceySwitch({
    super.key,
    required this.value,
    this.height = 22,
    this.borderWidth = 3.0,
    this.disabled = false,
    required this.onChanged,
  });

  void handleChanged([bool? newValue]) {
    if (newValue != null && onChanged != null) {
      onChanged!(newValue);
    } else if (newValue == null && onChanged != null && value != null) {
      onChanged!(!value!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final closedColor = theme.scaffoldBackgroundColor;

    final openedColor = theme.colorScheme.primary;

    final innerIndicatorSize = height - 4 * borderWidth;

    return CustomAnimatedToggleSwitch(
      active: !disabled,
      current: value,
      spacing: 10.0,
      values: const [false, true],
      animationDuration: AppTheme.defaultDurationMid,
      animationCurve: Curves.easeInOutSine,
      iconBuilder: (context, local, global) => const SizedBox(),
      onTap: (_) => handleChanged(),
      iconsTappable: false,
      onChanged: handleChanged,
      height: height,
      padding: EdgeInsets.all(borderWidth),
      indicatorSize: Size.square(height - 2 * borderWidth),
      foregroundIndicatorBuilder: (context, global) {
        final color = Color.lerp(closedColor, openedColor, global.position)!;

        return Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Container(
            width:
                innerIndicatorSize * 0.4 +
                global.position * innerIndicatorSize * 0.6,
            height: innerIndicatorSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: color,
            ),
          ),
        );
      },
      wrapperBuilder: (context, global, child) {
        final color = Color.lerp(closedColor, openedColor, global.position)!;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: child,
        );
      },
    );
  }
}
