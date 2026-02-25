import 'package:IceyPlayer/pages/home/controller.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../../constants/glass_settings.dart';

class BottomBar extends StatelessWidget {
  final List<MenuData> menu;
  final int selectedIndex;
  final VoidCallback onSearch;
  final Function(int) onTabSelected;

  const BottomBar({
    super.key,
    required this.menu,
    required this.selectedIndex,
    required this.onSearch,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassBottomBar(
      horizontalPadding: 16,
      quality: GlassQuality.standard,
      indicatorColor: theme.colorScheme.primary.withAlpha(55),
      glassSettings: RecommendedGlassSettings.bottomBar,
      iconSize: 20,
      selectedIconColor: theme.colorScheme.primary,
      unselectedIconColor: theme.iconTheme.color!,
      extraButton: GlassBottomBarExtraButton(
        icon: FluentIcons.search_12_regular,
        onTap: onSearch,
        label: "",
      ),
      tabs: menu
          .map(
            (e) => GlassBottomBarTab(
              label: e.label,
              icon: e.icon,
              selectedIcon: e.selectedIcon,
            ),
          )
          .toList(),
      selectedIndex: selectedIndex,
      onTabSelected: onTabSelected,
    );
  }
}
