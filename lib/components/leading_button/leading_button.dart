import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LeadingButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;

  const LeadingButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Ink(
      width: 36.sp,
      height: 36.sp,
      decoration: ShapeDecoration(
        color: theme.secondaryHeaderColor,
        shape: const CircleBorder(),
      ),
      child: IconButton(iconSize: 16.sp, icon: icon, onPressed: onTap),
    );
  }
}
