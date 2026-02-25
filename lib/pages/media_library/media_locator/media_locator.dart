import 'dart:math';

import 'package:IceyPlayer/components/high_material_wrapper/high_material_wrapper.dart';
import 'package:IceyPlayer/constants/glass_settings.dart';
import 'package:IceyPlayer/helpers/platform.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:keframe/keframe.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:responsive_builder/responsive_builder.dart';

class MediaLocator extends StatelessWidget {
  final bool showBackTop;
  final VoidCallback onLocate;
  final VoidCallback onBackTop;

  const MediaLocator({
    super.key,
    required this.showBackTop,
    required this.onLocate,
    required this.onBackTop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final paddingBottom = MediaQuery.of(context).viewPadding.bottom;

    final resultWidget = FrameSeparateWidget(
      child: Row(
        spacing: 8,
        children: [
          AnimatedSlide(
            offset: Offset(showBackTop ? 0 : 3, 0),
            curve: Curves.easeInOutSine,
            duration: AppTheme.defaultDurationMid,
            child: GlassPanel(
              padding: EdgeInsets.zero,
              settings: RecommendedGlassSettings.bottomBar,
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: onBackTop,
                child: SFIcon(
                  SFIcons.sf_arrow_up,
                  color: theme.colorScheme.onSurface.withAlpha(
                    AppTheme.defaultAlpha,
                  ),
                ),
              ),
            ),
          ),
          GlassPanel(
            padding: EdgeInsets.zero,
            settings: RecommendedGlassSettings.bottomBar,
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: onLocate,
              child: SFIcon(
                SFIcons.sf_dot_radiowaves_left_and_right,
                color: theme.colorScheme.onSurface.withAlpha(
                  AppTheme.defaultAlpha,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return OrientationLayoutBuilder(
      portrait: (context) => Positioned(
        bottom: PlatformHelper.isDesktop ? 100 : max(144 + paddingBottom, 166),
        right: 20,
        child: resultWidget,
      ),
      landscape: (context) => Positioned(
        bottom: paddingBottom + 64 + 12 + 16,
        right: 20,
        child: resultWidget,
      ),
    );
  }
}
