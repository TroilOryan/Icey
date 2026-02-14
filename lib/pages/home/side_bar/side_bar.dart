import 'package:IceyPlayer/pages/home/controller.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class SideBar extends StatelessWidget {
  final List<MenuData> menu;

  final bool opened;

  final int selectedIndex;

  final Function(int) onTabSelected;

  const SideBar({
    super.key,
    required this.menu,
    required this.opened,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final logo = Image.asset(
      "assets/images/logo.png",
      gaplessPlayback: true,
      height: 44,
      width: 44,
    );

    return AnimatedContainer(
      duration: AppTheme.defaultDuration,
      curve: Curves.easeInOutSine,
      width: opened ? 300 : 60,
      color: theme.cardTheme.color,
      padding: opened
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        spacing: 16,
        children: [
          Container(
            height: 60,
            child: opened
                ? Row(
                    spacing: 12,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      logo,
                      Text("Icey Player", style: theme.textTheme.titleMedium),
                    ],
                  )
                : logo,
          ),
          ...menu.map((e) {
            final selected = selectedIndex == menu.indexOf(e);

            final icon = Icon(e.icon, color: selected ? Colors.white : null);

            return Material(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.all(AppTheme.borderRadiusXxs),
              color: selected ? theme.colorScheme.primary : null,
              child: Ink(
                child: InkWell(
                  onTap: () => onTabSelected(menu.indexOf(e)),
                  child: Container(
                    width: double.infinity,
                    height: !opened ? 44 : null,
                    padding: opened
                        ? const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          )
                        : EdgeInsets.zero,
                    child: opened
                        ? Row(
                            spacing: 12,
                            children: [
                              icon,
                              Text(
                                e.label,
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  color: selected ? Colors.white : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: true,
                              ),
                            ],
                          )
                        : Center(child: icon),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
