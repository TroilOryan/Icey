import 'package:IceyPlayer/components/button/button.dart';
import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/components/page_wrapper/page_wrapper.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/constants/cache_key.dart';
import 'package:IceyPlayer/entities/media.dart';
import 'package:IceyPlayer/helpers/media_scanner/media_scanner.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signals/signals_flutter.dart';

import 'file_item.dart';
import "package:path/path.dart" as path;

part 'controller.dart';

part 'state.dart';



class MediaStorePage extends StatelessWidget {
  const MediaStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final filterShort = state.filterShort.watch(context),
        scanDir = state.scanDir.watch(context),
        filterDir = state.filterDir.watch(context);

    return PageWrapper(
      title: '媒体库',
      body: Column(
        spacing: 16.h,
        children: [
          ListCard(
            padding: EdgeInsets.zero,
            children: [
              ListItem(
                title: '过滤5s以下的音频',
                isSwitch: true,
                value: filterShort,
                onChanged: setFilterShort,
              ),
            ],
          ),
          ListCard(
            title: "扫描文件夹",
            children: scanDir
                .map(
                  (dir) => FileItem(
                    path: dir,
                    isFiltered: false,
                    onPressed: () => handleSwitchScanDirStatus(dir),
                  ),
                )
                .toList(),
          ),
          ListCard(
            title: "过滤文件夹",
            children: filterDir
                .map(
                  (dir) => FileItem(
                    path: dir,
                    isFiltered: true,
                    onPressed: () => handleSwitchFilterDirStatus(dir),
                  ),
                )
                .toList(),
          ),
          const Button(
            block: true,
            onPressed: MediaScanner.scanMedias,
            child: Text("开始扫描"),
          ),
        ],
      ),
    );
  }
}
