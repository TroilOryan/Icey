import 'package:flutter/material.dart';
import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/components/page_wrapper/page_wrapper.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:signals/signals_flutter.dart';

class AudioOutputPage extends StatefulWidget {
  const AudioOutputPage({super.key});

  @override
  State<AudioOutputPage> createState() => _AudioOutputPageState();
}

class _AudioOutputPageState extends State<AudioOutputPage> {
  @override
  Widget build(BuildContext context) {
    final audioFocus = settingsManager.audioFocus.watch(context);

    return PageWrapper(
      title: "音频输出",
      body: Column(
        spacing: 16,
        children: [
          ListCard(
            children: [
              ListItem(
                title: '不与其他应用一起播放(音频焦点)',
                desc: "开启后将不会与其他应用一起播放，该功能受系统不同策略表现效果有出入。",
                isSwitch: true,
                value: audioFocus,
                onChanged: settingsManager.setAudioFocus,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
