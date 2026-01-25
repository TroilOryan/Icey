import 'dart:typed_data';

import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/components/page_wrapper/page_wrapper.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/pages/settings/interface/theme_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signals_flutter/signals_flutter.dart';

final ImagePicker _picker = ImagePicker();

class InterfacePage extends StatelessWidget {
  const InterfacePage({super.key});

  Future<void> selectImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      image.readAsBytes().then((value) {
        settingsManager.setListBg(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightnessTheme = settingsManager.brightnessTheme.watch(context),
        isMaterialScrollBehavior = settingsManager.isMaterialScrollBehavior
            .watch(context),
        scrollHidePlayBar = settingsManager.scrollHidePlayBar.watch(context),
        coverShape = settingsManager.coverShape.watch(context),
        artCover = settingsManager.artCover.watch(context),
        wakelock = settingsManager.wakelock.watch(context),
        dynamicLight = settingsManager.dynamicLight.watch(context),
        immersive = settingsManager.immersive.watch(context),
        listBg = settingsManager.listBg.watch(context);

    return PageWrapper(
      title: '用户界面',
      body: Column(
        spacing: 16,
        children: [
          ListCard(
            spacing: 0,
            title: '用户界面',
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 16),
                child: Row(
                  spacing: 12,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: BrightnessTheme.values
                      .map(
                        (e) => ThemeCard(
                          activeValue: brightnessTheme.value,
                          value: e.value,
                          onTap: (value) => settingsManager.setBrightnessTheme(
                            BrightnessTheme.getByValue(value),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              ListItem(
                isPro: true,
                title: '层级过度滚动',
                desc: "重启后生效",
                isSwitch: true,
                value: isMaterialScrollBehavior,
                onChanged: settingsManager.setIsMaterialScrollBehavior,
              ),
              ListItem(
                title: '滚动隐藏播放条',
                isSwitch: true,
                value: scrollHidePlayBar,
                onChanged: settingsManager.setScrollHidePlayBar,
              ),
              ListItem(
                isPro: true,
                title: '媒体库自定义背景',
                trailing: listBg.isNotEmpty
                    ? Image.memory(
                        listBg,
                        gaplessPlayback: true,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : null,
                onTap: selectImage,
              ),
              Offstage(
                offstage: listBg.isEmpty,
                child: ListItem(
                  title: '删除当前背景',
                  onTap: () => settingsManager.setListBg(Uint8List(0)),
                ),
              ),
            ],
          ),
          ListCard(
            spacing: 0,
            title: '播放界面',
            padding: EdgeInsets.zero,
            children: [
              ListItem(
                title: '播放界面常亮',
                isSwitch: true,
                value: wakelock,
                onChanged: settingsManager.setWakelock,
              ),
              ListItem(
                title: '动态流光',
                isSwitch: true,
                isPro: true,
                value: dynamicLight,
                onChanged: settingsManager.setDynamicLight,
              ),
              ListItem(
                title: '歌词封面',
                isMultiSwitch: true,
                value: coverShape.name,
                values: CoverShape.values.map((e) => e.name).toList(),
                onMultiChanged: (value) =>
                    settingsManager.setCoverShape(CoverShape.getByName(value)),
              ),
              ListItem(
                title: '艺术封面',
                isSwitch: true,
                value: artCover,
                onChanged: settingsManager.setArtCover,
              ),
              ListItem(
                title: '高阶材质',
                onTap: () => context.push('/settings/interface/high_material'),
              ),
              ListItem(
                title: '沉浸模式',
                isSwitch: true,
                value: immersive,
                onChanged: settingsManager.setImmersive,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
