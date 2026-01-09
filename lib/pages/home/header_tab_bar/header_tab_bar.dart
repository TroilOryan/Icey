import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeaderTabBarItem extends StatelessWidget {
  final String label;

  const HeaderTabBarItem({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
      child: Tab(
        child: Align(alignment: Alignment.center, child: Text(label)),
      ),
    );
  }
}

class HeaderTabBar extends StatelessWidget {
  final bool offstage;
  final Function(int) onTap;

  const HeaderTabBar({super.key, required this.offstage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Offstage(
      offstage: offstage,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
        child: TabBar(
          onTap: onTap,
          tabs: [
            HeaderTabBarItem(label: '媒体库'),
            HeaderTabBarItem(label: '专辑'),
            HeaderTabBarItem(label: '艺术家'),
          ],
        ),
      ),
    );
  }
}
