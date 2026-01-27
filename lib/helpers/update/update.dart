import 'dart:io';

import 'package:IceyPlayer/build_config.dart';
import 'package:IceyPlayer/components/bottom_sheet/bottom_sheet.dart';
import 'package:IceyPlayer/components/button/button.dart';
import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/helpers/common.dart';
import 'package:IceyPlayer/helpers/toast/toast.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:IceyPlayer/http/init.dart';

import 'ua_type.dart';

abstract class UpdateHelper {
  // 检查更新
  static Future<void> checkUpdate(BuildContext context) async {
    if (kDebugMode || !settingsManager.autoUpdate.value) return;

    try {
      final res = await Request().get(
        'https://api.github.com/repos/TroilOryan/Icey/releases',
        options: Options(headers: {'user-agent': UaType.mob.ua}),
      );
      if (res.data is Map || res.data.isEmpty) {
        showToast('检查更新失败，请检查网络，或等待30分钟后再试。');
        return;
      }
      final data = res.data[0];

      final int latest =
          DateTime.parse(data['created_at']).millisecondsSinceEpoch ~/ 1000;
      if (BuildConfig.buildTime >= latest) {
      } else {
        final theme = Theme.of(context);

        Widget downloadBtn(String text, {String? ext}) => Button(
          onPressed: () => onDownload(data, ext: ext),
          child: Text(text),
        );

        scrollableBottomSheet(
          context: context,
          builder: (context) => [
            Text('🎉 发现新版本 ', style: theme.textTheme.titleMedium),
            ListCard(
              spacing: 16,
              children: [
                Text('${data['tag_name']}', style: theme.textTheme.titleMedium),
                Text('${data['body'] ?? "暂无内容"}'),
                GestureDetector(
                  onTap: () => CommonHelper.launchURL(
                    'https://github.com/TroilOryan/Icey/commits/main',
                  ),
                  child: Text(
                    "点此查看完整更新(即commit)内容",
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (Platform.isWindows) ...[
                  downloadBtn('zip', ext: 'zip'),
                  downloadBtn('exe', ext: 'exe'),
                ] else if (Platform.isLinux) ...[
                  downloadBtn('rpm', ext: 'rpm'),
                  downloadBtn('deb', ext: 'deb'),
                  downloadBtn('targz', ext: 'tar.gz'),
                ] else
                  downloadBtn('前往Github下载更新'),
              ],
            ),
          ],
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('failed to check update: $e');
    }
  }

  // 下载适用于当前系统的安装包
  static Future<void> onDownload(Map data, {String? ext}) async {
    try {
      void download(String plat) {
        if (data['assets'].isNotEmpty) {
          for (Map<String, dynamic> i in data['assets']) {
            final String name = i['name'];
            if (name.contains(plat) &&
                ((ext == null || ext.isEmpty) ? true : name.endsWith(ext))) {
              CommonHelper.launchURL(i['browser_download_url']);
              return;
            }
          }
          throw UnsupportedError('platform not found: $plat');
        }
      }

      if (Platform.isAndroid) {
        // 获取设备信息
        AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
        // [arm64-v8a]
        download(androidInfo.supportedAbis.first);
      } else {
        download(Platform.operatingSystem);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('download error: $e');
      // launchURL('${Constants.sourceCodeUrl}/releases/latest');
    }
  }
}
