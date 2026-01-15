import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/components/page_wrapper/page_wrapper.dart';
import 'package:IceyPlayer/models/pro/pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final enabled = proManager.enabled.watch(context);

    return PageWrapper(
      title: '设置',
      body: Column(
        spacing: 16,
        children: [
          ListCard(
            children: [
              ListItem(
                title: 'Icey Pro',
                icon: const Icon(SFIcons.sf_crown_fill, color: Colors.amber),
                desc: enabled ? '已启用' : "未启用",
                onTap: () => context.push('/settings/pro'),
              ),
            ],
          ),
          ListCard(
            children: [
              ListItem(
                title: '媒体库',
                icon: const Icon(SFIcons.sf_music_note),
                desc: '管理音频来源',
                onTap: () => context.push('/settings/media_store'),
              ),
              ListItem(
                title: '界面',
                icon: const Icon(SFIcons.sf_star_circle),
                desc: '播放器界面效果',
                onTap: () => context.push('/settings/interface'),
              ),
              ListItem(
                title: '歌词',
                icon: const Icon(SFIcons.sf_quote_bubble),
                onTap: () => context.push('/settings/lyric'),
              ),
              ListItem(
                title: '音频输出',
                icon: const Icon(SFIcons.sf_airplay_audio),
                onTap: () => context.push('/settings/audio_output'),
              ),
              ListItem(
                title: '关于',
                icon: const Icon(SFIcons.sf_info_circle),
                onTap: () => context.push('/settings/about'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
