import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/models/settings/settings.dart';

class MediaDrawer extends StatelessWidget {
  final VoidCallback onCloseDrawer;
  final Function(int) onSelected;

  const MediaDrawer({
    super.key,
    required this.onCloseDrawer,
    required this.onSelected,
  });

  void setListType(ListType value, int index) {
    settingsManager.setListType(value);

    onSelected(index);

    Future.delayed(const Duration(milliseconds: 50)).then((_) {
      onCloseDrawer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(24.w, 32.h, 0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListCard(
              highMaterial: true,
              children: [
                ListItem(
                  title: "媒体库",
                  trailing: SizedBox(),
                  onTap: () => setListType(ListType.media, 0),
                ),
                ListItem(
                  title: "专辑",
                  trailing: SizedBox(),
                  onTap: () => setListType(ListType.album, 1),
                ),
                ListItem(
                  title: "艺术家",
                  trailing: SizedBox(),
                  onTap: () => setListType(ListType.album, 2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
