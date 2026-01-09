import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/components/page_wrapper/page_wrapper.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signals/signals_flutter.dart';

class HighMaterialPage extends StatelessWidget {
  const HighMaterialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final highMaterial = settingsManager.highMaterial.watch(context);

    return PageWrapper(
      title: '高阶材质',
      body: Column(
        spacing: 16.h,
        children: [
          ListCard(
            spacing: 0,
            title: '播放界面',
            padding: EdgeInsets.zero,
            children: [
              ListItem(
                title: '高阶材质',
                desc: "开启后获得更好的视觉效果,但会导致偶现发热卡顿掉帧等问题",
                isSwitch: true,
                value: highMaterial,
                onChanged: settingsManager.setHighMaterial,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
