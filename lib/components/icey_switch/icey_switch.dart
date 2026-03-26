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

  @override
  Widget build(BuildContext context) {
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
      foregroundIndicatorBuilder: (context, global) =>
          _foregroundIndicatorBuilder(context, global),
      wrapperBuilder: (context, global, child) =>
          _wrapperBuilder(context, global, child),
    );
  }

  void handleChanged([bool? newValue]) {
    if (newValue != null && onChanged != null) {
      onChanged!(newValue);
    } else if (newValue == null && onChanged != null && value != null) {
      onChanged!(!value!);
    }
  }

  Widget _foregroundIndicatorBuilder(
    BuildContext context,
    DetailedGlobalToggleProperties<bool?> global,
  ) {
    final innerIndicatorSize = height - 4 * borderWidth;

    final theme = Theme.of(context);

    final closedColor = theme.scaffoldBackgroundColor;

    final openedColor = theme.colorScheme.primary;

    final color = Color.lerp(closedColor, openedColor, global.position)!;

    return Container(
      alignment: .center,
      decoration: const BoxDecoration(color: Colors.white, shape: .circle),
      child: Container(
        width:
            innerIndicatorSize * 0.4 +
            global.position * innerIndicatorSize * 0.6,
        height: innerIndicatorSize,
        decoration: BoxDecoration(borderRadius: .circular(20.0), color: color),
      ),
    );
  }

  Widget _wrapperBuilder(
    BuildContext context,
    GlobalToggleProperties<bool?> global,
    Widget child,
  ) {
    final theme = Theme.of(context);

    final closedColor = theme.scaffoldBackgroundColor;

    final openedColor = theme.colorScheme.primary;

    final color = Color.lerp(closedColor, openedColor, global.position)!;

    return DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: .circular(50.0)),
      child: child,
    );
  }
}
