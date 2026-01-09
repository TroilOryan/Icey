import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ScreenType {
  /// height <= 900
  small,

  /// 900 < height < 1100
  medium,

  /// height >= 1100
  large,
}

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, ScreenType screenType) builder;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    if (screenSize.height <= 600.h) {
      return builder(context, ScreenType.small);
    } else if (screenSize.height > 600.h && screenSize.height < 900.h) {
      return builder(context, ScreenType.medium);
    } else {
      return builder(context, ScreenType.large);
    }
  }
}
