import 'package:flutter/material.dart';

class HeaderTabBarItem extends StatelessWidget {
  final String label;
  final bool isLandscape;
  final bool active;

  const HeaderTabBarItem({
    super.key,
    required this.label,
    this.isLandscape = false,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final child = Align(
      alignment: Alignment.center,
      child: Text(
        label,
        style: theme.textTheme.bodyMedium!.copyWith(
          color: active ? theme.colorScheme.onSurface : null,
        ),
      ),
    );

    if (isLandscape) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(50),
        ),
        child: child,
      );
    }

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
      child: Tab(child: child),
    );
  }
}

class HeaderTabBar extends StatelessWidget {
  final bool offstage;
  final bool? isLandscape;
  final Function(int) onTap;

  const HeaderTabBar({
    super.key,
    required this.offstage,
    this.isLandscape,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Offstage(
      offstage: offstage,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Builder(
          builder: (context) {
            if (isLandscape == true) {
              return Padding(
                padding: EdgeInsetsGeometry.only(top: 32),
                child: Column(
                  spacing: 16,
                  children: [
                    HeaderTabBarItem(label: '媒体库', isLandscape: true),
                    HeaderTabBarItem(label: '专辑', isLandscape: true),
                    HeaderTabBarItem(label: '艺术家', isLandscape: true),
                  ],
                ),
              );
            }

            return TabBar(
              onTap: onTap,
              tabs: [
                HeaderTabBarItem(label: '媒体库'),
                HeaderTabBarItem(label: '专辑'),
                HeaderTabBarItem(label: '艺术家'),
              ],
            );
          },
        ),
      ),
    );
  }
}
