import 'package:IceyPlayer/components/high_material_wrapper/high_material_wrapper.dart';
import 'package:IceyPlayer/entities/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:keframe/keframe.dart';
import 'package:signals_flutter/signals_flutter.dart';

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
      padding: EdgeInsets.fromLTRB(24.w, 0.h, 24.w, 16.h),
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
                prefixIcon: Icon(SFIcons.sf_magnifyingglass, size: 16.sp),
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
