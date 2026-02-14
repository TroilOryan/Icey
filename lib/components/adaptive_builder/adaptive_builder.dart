import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AdaptiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext) mobile;
  final Widget Function(BuildContext)? landscape;
  final Widget Function(BuildContext)? tablet;
  final Widget Function(BuildContext)? desktop;

  const AdaptiveBuilder({
    super.key,
    required this.mobile,
    this.landscape,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationLayoutBuilder(
      portrait: mobile,
      landscape: landscape ?? tablet ?? desktop ?? mobile,
    );
  }
}
