import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../theme/theme.dart';

class SheetItem extends StatelessWidget {
  final bool active;
  final String label;
  final VoidCallback onTap;

  const SheetItem({
    super.key,
    this.active = false,
    required this.label,
    required this.onTap,
  });

  void handleTap(BuildContext context) {
    onTap();

    if (context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textTheme = theme.textTheme.titleSmall!.copyWith(
      fontWeight: FontWeight.w500,
    );

    return Material(
      clipBehavior: Clip.antiAlias,
      color: active
          ? theme.colorScheme.primaryContainer
          : theme.cardTheme.color,
      borderRadius: BorderRadius.all(AppTheme.borderRadiusSm),
      child: Ink(
        child: InkWell(
          onTap: () => handleTap(context),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            child: Row(
              children: [
                Text(
                  label,
                  style: textTheme.copyWith(
                    color: active ? theme.colorScheme.primary : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
