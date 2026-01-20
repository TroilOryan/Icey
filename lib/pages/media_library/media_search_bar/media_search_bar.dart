import 'package:IceyPlayer/components/high_material_wrapper/high_material_wrapper.dart';
import 'package:IceyPlayer/entities/media.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:keframe/keframe.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class MediaSearchBar extends StatelessWidget {
  final bool offstage;
  final FocusNode focusNode;
  final List<MediaEntity> mediaList;
  final VoidCallback onTap;

  const MediaSearchBar({
    super.key,
    required this.offstage,
    required this.focusNode,
    required this.mediaList,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (offstage) {
      return SizedBox.shrink();
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
      sliver: SliverToBoxAdapter(
        child: FrameSeparateWidget(
          child: HighMaterialWrapper(
            borderRadius: BorderRadius.all(AppTheme.borderRadiusLg),
            builder: (highMaterial) => TextField(
              focusNode: focusNode,
              onTap: onTap,
              decoration: InputDecoration(
                fillColor: theme.cardTheme.color!.withAlpha(
                  highMaterial ? AppTheme.defaultAlphaLight : 255,
                ),
                prefixIcon: Icon(SFIcons.sf_magnifyingglass, size: 16),
                hint: Text(
                  "在${mediaList.length}个媒体中搜索",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
      sliver: SliverToBoxAdapter(
        child: FrameSeparateWidget(
          child: GlassPanel(
            padding: EdgeInsets.zero,
            child: TextField(
              focusNode: focusNode,
              onTap: onTap,
              decoration: InputDecoration(
                fillColor: Colors.transparent,
                prefixIcon: Icon(SFIcons.sf_magnifyingglass, size: 16),
                hint: Text(
                  "在${mediaList.length}个媒体中搜索",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
