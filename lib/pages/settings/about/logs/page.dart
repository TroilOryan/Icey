import 'dart:convert';

import 'package:IceyPlayer/components/bottom_sheet/bottom_sheet.dart';
import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/components/page_wrapper/page_wrapper.dart';
import 'package:IceyPlayer/helpers/logs/logs.dart';
import 'package:IceyPlayer/pages/settings/about/logs/info_card/info_card.dart';
import 'package:IceyPlayer/pages/settings/about/logs/state.dart';
import 'package:catcher_2/model/platform_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';

part 'controller.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final controller = LogsController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller.onInit();
  }

  @override
  Widget build(BuildContext context) {
    final latestLog = controller.state.latestLog.watch(context),
        logs = controller.state.logs.watch(context);

    final colorScheme = Theme.of(context).colorScheme;

    final theme = Theme.of(context);

    return PageWrapper(
      title: "错误日志",
      body: Column(
        spacing: 16.h,
        children: [
          ListCard(
            spacing: 0,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            children: [
              if (latestLog != null)
                Row(
                  spacing: 12.w,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InfoCard(
                      icon: Icons.info,
                      label: '设备信息',
                      onTap: () => controller.showInfo(
                        "设备信息",
                        latestLog.deviceParameters,
                        context,
                      ),
                    ),
                    InfoCard(
                      icon: Icons.apps,
                      label: '应用信息',
                      onTap: () => controller.showInfo(
                        "应用信息",
                        latestLog.applicationParameters,
                        context,
                      ),
                    ),
                    InfoCard(
                      icon: Icons.code,
                      label: '编译信息',
                      onTap: () => controller.showInfo(
                        "编译信息",
                        latestLog.customParameters,
                        context,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          ListCard(
            title: "历史报错",
            children: logs
                .map(
                  (log) => ListItem(
                    title: log.error.toString(),
                    desc: log.dateTime.toString(),
                    onTap: () => context.push(
                      '/settings/about/logs/detail',
                      extra: {"error": log},
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
