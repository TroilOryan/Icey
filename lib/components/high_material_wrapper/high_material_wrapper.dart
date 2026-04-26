
import 'package:IceyPlayer/constants/glass_settings.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:signals/signals_flutter.dart';

class HighMaterialWrapper extends StatelessWidget {
  final bool disabled;
  final double blur;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration Function(bool)? decoration;
  final Clip Function(bool)? clipBehavior;
  final Widget Function(bool) builder;

  const HighMaterialWrapper({
    super.key,
    this.disabled = false,
    this.blur = 12,
    this.decoration,
    this.borderRadius,
    this.padding,
    this.margin,
    this.clipBehavior,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final highMaterial = settingsManager.highMaterial.watch(context),
        listBg = settingsManager.listBg.watch(context);

    final obscure = highMaterial && listBg.isNotEmpty && !disabled;

    return Builder(
      builder: (context) {
        if (obscure) {
          return _buildHighMaterial();
        }

        return _buildNormalMaterial();
      },
    );
  }

  Widget _buildHighMaterial() {
    return GlassPanel(
      settings: RecommendedGlassSettings.bottomBar,
      padding: padding ?? .zero,
      margin: margin,
      child: builder(true),
    );
  }

  Widget _buildNormalMaterial() {
    return Container(
      padding: padding,
      margin: margin,
      clipBehavior: clipBehavior != null ? clipBehavior!(false) : .antiAlias,
      decoration: decoration != null
          ? decoration!(false)
          : BoxDecoration(borderRadius: borderRadius),
      child: builder(false),
    );
  }
}
