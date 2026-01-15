import 'package:IceyPlayer/components/button/button.dart';
import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/components/page_wrapper/page_wrapper.dart';
import 'package:IceyPlayer/models/pro/pro.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';

class ProPage extends StatelessWidget {
  const ProPage({super.key});

  @override
  Widget build(BuildContext context) {
    final enabled = proManager.enabled.watch(context);

    return PageWrapper(
      title: 'Icey Pro',
      body: Column(
        spacing: 16,
        children: [
          const ListCard(
            spacing: 0,
            title: '会员功能',
            padding: EdgeInsets.zero,
            children: [
              ListItem(title: '动态流光', desc: "播放界面动态流光效果"),
              ListItem(title: '强行卡拉OK歌词', desc: "对于非卡拉OK歌词,强行实现卡拉OK效果"),
              ListItem(title: '更多功能', desc: "听歌统计,仿真播放器模式...敬请期待"),
            ],
          ),
          Button(
            disabled: enabled,
            block: true,
            child: Text(enabled ? "已激活" : "点击付款"),
            onPressed: () => context.push("/settings/pro/pay"),
          ),
        ],
      ),
    );
  }
}
