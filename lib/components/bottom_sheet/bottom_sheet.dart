import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';

scrollableBottomSheet({
  required BuildContext context,
  required List<Widget> Function(BuildContext) builder,
  isDismissible = true,
}) {
  return showModalBottomSheet(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    useRootNavigator: true,
    isDismissible: isDismissible,
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: AppTheme.borderRadiusLg),
    ),
    builder: (context) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: builder(context),
            ),
          ),
        ),
      );
    },
  );
}

bottomSheet({
  required BuildContext context,
  required Widget Function(BuildContext, ScrollController?) builder,
  isDismissible = true,
  initHeight = 0.6,
  minHeight = 0.6,
  maxHeight = 0.9,
}) {
  return showFlexibleBottomSheet(
    bottomSheetColor: Theme.of(context).scaffoldBackgroundColor,
    duration: AppTheme.defaultDurationLong,
    initHeight: initHeight,
    minHeight: minHeight,
    maxHeight: maxHeight,
    isDismissible: isDismissible,
    isCollapsible: false,
    isModal: true,
    isSafeArea: true,
    bottomSheetBorderRadius: BorderRadius.all(AppTheme.borderRadiusLg),
    context: context,
    builder: (context, controller, _) => Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Builder(builder: (context) => builder(context, controller)),
    ),
  );
}
