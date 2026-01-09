import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:IceyPlayer/components/high_material_wrapper/high_material_wrapper.dart';

import '../../theme/theme.dart';

class ListCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final double? spacing;
  final bool highMaterial;
  final EdgeInsetsGeometry? padding;

  const ListCard({
    super.key,
    this.title,
    required this.children,
    this.highMaterial = false,
    this.spacing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final leading = [];

    final theme = Theme.of(context);

    if (title != null) {
      leading.add(
        Container(
          margin: EdgeInsets.only(left: 8.w),
          child: Text(title!, style: theme.textTheme.bodyMedium),
        ),
      );
    }

    return Column(
      spacing: 8.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...leading,
        highMaterial
            ? HighMaterialWrapper(
          padding:
          padding ??
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: (highMaterial) => BoxDecoration(
            borderRadius: BorderRadius.all(AppTheme.borderRadiusMd),
            color: theme.cardTheme.color!.withAlpha(
              highMaterial
                  ? AppTheme.defaultAlphaLight
                  : AppTheme.defaultAlpha,
            ),
          ),
          builder: (_) => Column(
            spacing: spacing ?? 12.h,
            children: children.isNotEmpty
                ? children
                : [Text("暂无内容", style: theme.textTheme.bodyMedium)],
          ),
        )
            : Container(
          width: double.infinity,
          padding:
          padding ??
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.all(AppTheme.borderRadiusMd),
          ),
          child: Column(
            spacing: spacing ?? 12.h,
            children: children.isNotEmpty
                ? children
                : [Text("暂无内容", style: theme.textTheme.bodyMedium)],
          ),
        ),
      ],
    );
  }
}
