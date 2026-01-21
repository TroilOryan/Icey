import 'dart:math';

import 'package:IceyPlayer/components/high_material_wrapper/high_material_wrapper.dart';
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

    final paddingBottom = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: max(106 + paddingBottom, 116),
      right: 20,
      child: FrameSeparateWidget(
        child: Offstage(
          offstage: offstage,
          child: HighMaterialWrapper(
            borderRadius: const BorderRadius.all(Radius.circular(100)),
            clipBehavior: (highMaterial) =>
                highMaterial ? Clip.antiAlias : Clip.none,
            builder: (highMaterial) => highMaterial
                ? GlassPanel(
                    shape: LiquidOval(),
                    padding: EdgeInsets.zero,
                    child: FloatingActionButton(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shape: const CircleBorder(),
                      onPressed: onTap,
                      child: SFIcon(
                        SFIcons.sf_dot_radiowaves_left_and_right,
                        color: theme.colorScheme.onSurface.withAlpha(
                          AppTheme.defaultAlpha,
                        ),
                      ),
                    ),
                  )
                : FloatingActionButton(
                    backgroundColor: theme.cardTheme.color,
                    elevation: 6,
                    shape: const CircleBorder(),
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
