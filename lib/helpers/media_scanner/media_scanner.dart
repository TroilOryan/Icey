import "dart:convert";
import "dart:io";

import "package:IceyPlayer/helpers/platform.dart";
import "package:IceyPlayer/src/rust/api/tag_reader.dart";
import "package:audio_query/audio_query.dart";
import "package:audio_query/entities.dart" hide ArtworkColorEntity;
import "package:IceyPlayer/constants/box_key.dart";
import "package:IceyPlayer/constants/cache_key.dart";
import "package:IceyPlayer/entities/media.dart";
import "package:IceyPlayer/event_bus/event_bus.dart";
import "package:IceyPlayer/helpers/common.dart";
import "package:IceyPlayer/helpers/toast/toast.dart";
import "package:IceyPlayer/permission/audio.dart";
import "package:executor/executor.dart";
import "package:file_picker/file_picker.dart";

final audioQuery = AudioQuery();

final _mediaBox = Boxes.mediaBox, _settingsBox = Boxes.settingsBox;

class MediaScanner {
  static Future<void> _scanMediasDesktop([bool? silent]) async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        return;
      }

      await _mediaBox.clear();

      eventBus.fire(ScanMediaStatus(true, silent));

      final applicationSupportDirectory = await CommonHelper().getAppDataDir();

      final stream = buildIndexFromFoldersRecursively(
        folders: [selectedDirectory],
        indexPath: applicationSupportDirectory.path,
      );

      List<AudioEntity> audios = [];

      stream.listen(
        (res) {},
        onDone: () async {
          final List<String> filterDir = _settingsBox.get(
            CacheKey.Settings.filterDir,
            defaultValue: <String>[],
          );

          final filterShort = _settingsBox.get(
            CacheKey.Settings.filterShort,
            defaultValue: true,
          );

          final supportPath = applicationSupportDirectory.path;

          final indexPath = "$supportPath\\index.json";

          final indexStr = File(indexPath).readAsStringSync();

          final Map indexJson = json.decode(indexStr);
          final List foldersJson = indexJson["folders"];
          // final List<AudioFolder> folders = [];

          for (Map folderMap in foldersJson) {
            final List audiosJson = folderMap["audios"];
            for (Map audioMap in audiosJson) {
              audios.add(AudioEntity(audioMap));
              eventBus.fire(ScanMediaAdd(audios));
            }

            // folders.add(AudioFolder.fromMap(folderMap, audios));
          }

          if (audios.isEmpty) {
            showToast("本地没有音乐或者系统拒绝访问 QAQ");

            return;
          }

          late List<MediaEntity> mediaList;

          mediaList = _filterAudios(
            audios,
            filterShort,
            filterDir,
            5000, // 统一使用毫秒
          );

          await _mediaBox.addAll(mediaList);

          final scanDir = CommonHelper.getParentFolders(
            mediaList.map((e) => e.data).toList(),
          );

          final dir = Directory('${CommonHelper.tmpDir.path}/IceyCover');

          if (!dir.existsSync()) {
            dir.createSync();
          }

          final executor = Executor(concurrency: 300);

          for (MediaEntity media in mediaList) {
            executor.scheduleTask(() async {
              final cover = await getArtworkFromPath(
                path: media.id,
                width: 256,
                height: 256,
              );

              String tmpPath = "${dir.path}/${media.title}.jpg";

              final tmpFile = File(tmpPath);

              if (cover != null && !tmpFile.existsSync()) {
                final tmpFile = File(tmpPath);
                await tmpFile.writeAsBytes(cover);
              }
            });
          }

          await executor.join(withWaiting: true);

          await executor.close();

          eventBus.fire(ScanMediaStatus(false, silent));

          _settingsBox.put(CacheKey.Settings.scanDir, scanDir);
        },
      );
    } catch (e) {
      print(e);
    }

    return;
  }

  static Future<void> _scanMediasMobile([bool? silent]) async {
    final hasPermission = await requestPermissions();

    if (!hasPermission) {
      return;
    }

    await _mediaBox.clear();

    final stream = await audioQuery.queryAudios();

    List<AudioEntity> audios = [];

    eventBus.fire(ScanMediaStatus(true, silent));

    stream.listen(
      (res) {
        eventBus.fire(ScanMediaAdd(res));
        audios = res;
      },
      onDone: () async {
        eventBus.fire(ScanMediaStatus(false, silent));

        if (audios.isEmpty) {
          showToast("本地没有音乐或者系统拒绝访问 QAQ");

          return;
        }

        final List<String> filterDir = _settingsBox.get(
          CacheKey.Settings.filterDir,
          defaultValue: <String>[],
        );

        final filterShort = _settingsBox.get(
          CacheKey.Settings.filterShort,
          defaultValue: true,
        );

        late List<MediaEntity> mediaList;

        mediaList = _filterAudios(
          audios,
          filterShort,
          filterDir,
          5000, // 统一使用毫秒
        );

        await _mediaBox.addAll(mediaList);

        final scanDir = CommonHelper.getParentFolders(
          mediaList.map((e) => e.data).toList(),
        );

        _settingsBox.put(CacheKey.Settings.scanDir, scanDir);
      },
    );
  }

  /// 过滤音频列表
  static List<MediaEntity> _filterAudios(
    List<AudioEntity> audios,
    bool filterShort,
    List<String> filterDir,
    int minDurationMs,
  ) {
    if (filterShort == true) {
      return audios
          .map((audio) => MediaEntity.fromMediaStore(audio))
          .where(
            (audio) =>
                (audio.duration ?? 0) > minDurationMs &&
                filterDir.every((dir) => !audio.data.contains(dir)),
          )
          .toList();
    } else {
      return audios
          .map((audio) => MediaEntity.fromMediaStore(audio))
          .where((audio) => filterDir.every((dir) => !audio.data.contains(dir)))
          .toList();
    }
  }

  /// 扫描音频文件
  static void scanMedias([bool? silent]) async {
    if (PlatformHelper.isDesktop) {
      _scanMediasDesktop(silent);

      return;
    }

    _scanMediasMobile(silent);
  }
}
