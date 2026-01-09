import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/components/page_wrapper/page_wrapper.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signals_flutter/signals_flutter.dart';

class LyricPage extends StatelessWidget {
  const LyricPage({super.key});

  @override
  Widget build(BuildContext context) {
    final karaoke = settingsManager.karaoke.watch(context),
        fakeEnhanced = settingsManager.fakeEnhanced.watch(context);

    return PageWrapper(
      title: '歌词',
      body: Column(
        spacing: 16.h,
        children: [
          ListCard(
            spacing: 0,
            title: '播放界面',
            padding: EdgeInsets.zero,
            children: [
              ListItem(
                title: '卡拉OK歌词',
                desc: "对于卡拉OK歌词,实现逐字效果",
                isSwitch: true,
                value: karaoke,
                onChanged: settingsManager.setKaraoke,
              ),
              ListItem(
                title: '强行卡拉OK歌词',
                desc: "对于非卡拉OK歌词,强行实现逐字效果",
                isPro: true,
                isSwitch: true,
                value: fakeEnhanced,
                onChanged: settingsManager.setFakeEnhanced,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
