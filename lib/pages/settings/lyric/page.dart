import 'package:IceyPlayer/components/bottom_sheet/bottom_sheet.dart';
import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/components/page_wrapper/page_wrapper.dart';
import 'package:IceyPlayer/constants/settings.dart';
import 'package:IceyPlayer/models/lyric/lyric.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

class LyricPage extends StatelessWidget {
  const LyricPage({super.key});

  void handleSetLyricOverlayColor(BuildContext context) {
    final theme = Theme.of(context);

    scrollableBottomSheet(
      context: context,
      builder: (context) => [
        Text("字体颜色", style: theme.textTheme.titleMedium),
        ListCard(
          children: Settings.textColor
              .map(
                (e) => ListItem(
                  title: e.label,
                  trailing: Container(
                    width: 33,
                    height: 33,
                    decoration: BoxDecoration(
                      color: e.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onTap: () {
                    lyricManager.setOverlayLyricColor(e.color.toARGB32());

                    context.pop();
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final karaoke = settingsManager.karaoke.watch(context),
        fakeEnhanced = settingsManager.fakeEnhanced.watch(context),
        lyricOverlay = settingsManager.lyricOverlay.watch(context);

    final deviceHeight = MediaQuery.of(context).size.height;

    final deviceWidth = MediaQuery.of(context).size.width;

    final overlayLyricSize = lyricManager.overlayLyricSize.watch(context),
        overlayLyricWidth = lyricManager.overlayLyricWidth.watch(context),
        overlayLyricColor = lyricManager.overlayLyricColor.watch(context),
        overlayLyricX = lyricManager.overlayLyricX.watch(context),
        overlayLyricY = lyricManager.overlayLyricY.watch(context);

    return PageWrapper(
      title: '歌词',
      body: Column(
        spacing: 16,
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
          ListCard(
            spacing: 0,
            title: '桌面歌词',
            padding: EdgeInsets.zero,
            children: [
              ListItem(
                title: '状态栏歌词',
                desc: "悬浮状态栏歌词",
                isPro: true,
                isSwitch: true,
                value: lyricOverlay,
                onChanged: settingsManager.setLyricOverlay,
              ),
              if (lyricOverlay)
                ListItem(
                  title: "字体大小",
                  trailing: Slider(
                    value: overlayLyricSize,
                    min: 16,
                    max: 24,
                    label: overlayLyricSize.toString(),
                    divisions: 8,
                    onChanged: lyricManager.setOverlayLyricSize,
                  ),
                ),
              if (lyricOverlay)
                ListItem(
                  title: "歌词宽度",
                  trailing: Slider(
                    value: overlayLyricWidth,
                    label: overlayLyricWidth.floor().toStringAsFixed(1),
                    min: 50,
                    max: deviceWidth,
                    divisions: (deviceWidth - 50).toInt(),
                    onChanged: lyricManager.setOverlayLyricWidth,
                  ),
                ),
              if (lyricOverlay)
                ListItem(
                  title: "字体颜色",
                  trailing: Container(
                    width: 33,
                    height: 33,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(overlayLyricColor),
                    ),
                  ),
                  onTap: () => handleSetLyricOverlayColor(context),
                ),
              if (lyricOverlay)
                ListItem(
                  title: "水平位置",
                  trailing: Slider(
                    value: overlayLyricX,
                    label: overlayLyricX.toStringAsFixed(1),
                    min: 0,
                    max: deviceWidth,
                    divisions: deviceWidth.toInt(),
                    onChanged: lyricManager.setOverlayLyricX,
                  ),
                ),
              if (lyricOverlay)
                ListItem(
                  title: "垂直位置",
                  trailing: Slider(
                    value: overlayLyricY,
                    label: overlayLyricY.toStringAsFixed(1),
                    min: 0,
                    max: 50,
                    divisions: 50,
                    onChanged: lyricManager.setOverlayLyricY,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
