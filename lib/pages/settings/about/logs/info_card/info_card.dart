import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sficon/flutter_sficon.dart';

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const InfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Flexible(
      child: Material(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.all(AppTheme.borderRadiusSm),
        color: theme.scaffoldBackgroundColor,
        child: Ink(
          child: InkWell(
            onTap: () => onTap(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12.h,
                children: [
                  Icon(icon, size: 18.sp),
                  Text(label, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
