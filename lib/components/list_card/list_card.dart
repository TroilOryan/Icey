import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:IceyPlayer/components/high_material_wrapper/high_material_wrapper.dart';
import 'package:signals/signals_flutter.dart';

import '../../theme/theme.dart';

class ListCard extends StatefulWidget {
  final String? title;
  final Widget? action;
  final List<Widget> children;
  final double? spacing;
  final bool highMaterial;
  final bool collapsible;
  final EdgeInsetsGeometry? padding;

  const ListCard({
    super.key,
    this.title,
    this.action,
    required this.children,
    this.highMaterial = false,
    this.collapsible = false,
    this.spacing,
    this.padding,
  });

  @override
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  final collapsed = signal(true);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> leading = [];

    final theme = Theme.of(context);

    final _collapsed = collapsed.watch(context);

    if (widget.title != null) {
      leading.add(
        Container(
          margin: EdgeInsets.only(left: 8.w),
          child: Text(widget.title!, style: theme.textTheme.bodyMedium),
        ),
      );
    }

    if (widget.action != null) {
      leading = [
        Flexible(
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [...leading, widget.action!],
          ),
        ),
      ];
    }

    if (widget.collapsible) {
      leading = [
        Flexible(
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              ...leading,
              IconButton(
                onPressed: () {
                  collapsed.value = !collapsed.value;
                },
                icon: Icon(_collapsed ? Icons.expand_more : Icons.expand_less),
              ),
            ],
          ),
        ),
      ];
    }

    return Column(
      spacing: 8.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: leading),

        if (!_collapsed || !widget.collapsible)
          widget.highMaterial
              ? HighMaterialWrapper(
                  padding:
                      widget.padding ??
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
                    spacing: widget.spacing ?? 12.h,
                    children: widget.children.isNotEmpty
                        ? widget.children
                        : [Text("暂无内容", style: theme.textTheme.bodyMedium)],
                  ),
                )
              : Container(
                  width: double.infinity,
                  padding:
                      widget.padding ??
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.all(AppTheme.borderRadiusMd),
                  ),
                  child: Column(
                    spacing: widget.spacing ?? 12.h,
                    children: widget.children.isNotEmpty
                        ? widget.children
                        : [Text("暂无内容", style: theme.textTheme.bodyMedium)],
                  ),
                ),
      ],
    );
  }
}
