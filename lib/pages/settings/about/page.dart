import 'package:IceyPlayer/build_config.dart';
import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/components/page_wrapper/page_wrapper.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:signals/signals_flutter.dart';

part 'state.dart';

part 'controller.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    onInit();
  }

  @override
  Widget build(BuildContext context) {
    final version = state.version.watch(context);

    final autoUpdate = settingsManager.autoUpdate.watch(context);

    return PageWrapper(
      title: '关于',
      body: Column(
        spacing: 16,
        children: [
          const ListCard(
            title: "开发团队",
            padding: EdgeInsets.zero,
            children: [
              ListItem(title: '开发者', desc: "Vince He"),
              ListItem(title: '设计师', desc: "然然听不懂"),
            ],
          ),
          const ListCard(
            title: "特别鸣谢",
            padding: EdgeInsets.zero,
            children: [ListItem(title: "制作人员", desc: "牧以诚 安酥雨")],
          ),
          ListCard(
            title: "版本信息",
            padding: EdgeInsets.zero,
            children: [ListItem(title: '版本号', desc: BuildConfig.versionName)],
          ),
          ListCard(
            title: "应用设置",
            padding: EdgeInsets.zero,
            children: [
              ListItem(
                title: '启动时检查更新',
                isSwitch: true,
                value: autoUpdate,
                onChanged: settingsManager.setAutoUpdate,
              ),
              ListItem(
                title: '错误日志',
                onTap: () => context.push("/settings/about/logs"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
