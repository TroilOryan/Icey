import 'package:IceyPlayer/pages/home/controller.dart';
import 'package:flutter/material.dart';

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
    return Container(
      width: opened ? 300 : 50,
      child: Column(
        children: menu
            .map(
              (e) => GestureDetector(
                onTap: () => onTabSelected(menu.indexOf(e)),
                child: Text(e.label),
              ),
            )
            .toList(),
      ),
    );
  }
}
