import 'dart:math';

import 'package:IceyPlayer/components/high_material_wrapper/high_material_wrapper.dart';
import 'package:IceyPlayer/constants/glass_settings.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:keframe/keframe.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class MediaLocator extends StatelessWidget {
  final bool offstage;
  final VoidCallback onTap;

  const MediaLocator({super.key, required this.offstage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final paddingBottom = MediaQuery.of(context).viewPadding.bottom;

    return Positioned(
      bottom: max(144 + paddingBottom, 166),
      right: 20,
      child: FrameSeparateWidget(
        child: Offstage(
          offstage: offstage,
          child: GlassPanel(
            padding: EdgeInsets.zero,
            settings: RecommendedGlassSettings.bottomBar,
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: onTap,
              child: SFIcon(
                SFIcons.sf_dot_radiowaves_left_and_right,
                color: theme.colorScheme.onSurface.withAlpha(
                  AppTheme.defaultAlpha,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
