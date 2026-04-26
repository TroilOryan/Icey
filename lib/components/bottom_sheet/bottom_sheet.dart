import 'package:IceyPlayer/helpers/platform.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

Future<dynamic> scrollableBottomSheet({
  required BuildContext context,
  required List<Widget> Function(BuildContext) builder,
  isDismissible = true,
}) {
  if (PlatformHelper.isDesktop) {
    return SmartDialog.show(
      animationType: .fade,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: .circular(AppTheme.borderRadiusLg),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.3,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            padding: .only(
              bottom:
                  MediaQuery.of(context).viewInsets.bottom +
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: const .symmetric(horizontal: 24, vertical: 16),
              child: Column(
                spacing: 16,
                crossAxisAlignment: .start,
                mainAxisSize: .min,
                children: builder(context),
              ),
            ),
          ),
        );
      },
    );
  }

  return showModalBottomSheet(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    useRootNavigator: true,
    isDismissible: isDismissible,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: .vertical(top: .circular(AppTheme.borderRadiusLg)),
    ),
    builder: (context) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: .only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom,
          ),
          child: Padding(
            padding: const .symmetric(horizontal: 24, vertical: 16),
            child: Column(
              spacing: 16,
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: builder(context),
            ),
          ),
        ),
      );
    },
  );
}

Future<dynamic> bottomSheet({
  required BuildContext context,
  required Widget Function(BuildContext, ScrollController?) builder,
  isDismissible = true,
  initHeight = 0.6,
  minHeight = 0.6,
  maxHeight = 0.9,
}) {
  if (PlatformHelper.isDesktop) {
    return SmartDialog.show(
      animationType: .fade,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: .circular(AppTheme.borderRadiusLg),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.3,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Padding(
            padding: .fromLTRB(
              24,
              16,
              24,
              16 +
                  MediaQuery.of(context).viewInsets.bottom +
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Builder(builder: (context) => builder(context, null)),
          ),
        );
      },
    );
  }

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
    bottomSheetBorderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
    context: context,
    builder: (context, controller, _) => Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 +
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      child: Builder(builder: (context) => builder(context, controller)),
    ),
  );
}
