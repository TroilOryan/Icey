import "package:audio_query/audio_query.dart";
import "package:audio_query/entities.dart" hide ArtworkColorEntity;
import "package:IceyPlayer/constants/box_key.dart";
import "package:IceyPlayer/constants/cache_key.dart";
import "package:IceyPlayer/entities/media.dart";
import "package:IceyPlayer/event_bus/event_bus.dart";
import "package:IceyPlayer/helpers/common.dart";
import "package:IceyPlayer/helpers/toast/toast.dart";
import "package:IceyPlayer/permission/audio.dart";

const MEDIA_EXTENSTIONS = [
  ".mp3",
  ".wav",
  ".flac",
  ".m4a",
  ".aac",
  ".ogg",
  ".opus",
];

final audioQuery = AudioQuery();

final _mediaBox = Boxes.mediaBox, _settingsBox = Boxes.settingsBox;

class MediaScanner {
  /// 扫描音频文件
  static void scanMedias([bool? silent]) async {
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

        final List<String> filterDir = _settingsBox.get(
          CacheKey.Settings.filterDir,
          defaultValue: <String>[],
        );

        final filterShort = _settingsBox.get(
          CacheKey.Settings.filterShort,
          defaultValue: true,
        );

        if (audios.isEmpty) {
          showToast("本地没有音乐或者系统拒绝访问 QAQ");

          return;
        }

        late List<MediaEntity> mediaList;

        if (filterShort == true) {
          mediaList = audios
              .map((MediaEntity.fromMediaStore))
              .where(
                (audio) =>
                    (audio.duration ?? 0) > 5000 &&
                    filterDir.every((dir) => !audio.data.contains(dir)),
              )
              .toList();
        } else {
          mediaList = audios
              .map((MediaEntity.fromMediaStore))
              .where(
                (audio) => filterDir.every((dir) => !audio.data.contains(dir)),
              )
              .toList();
        }

        await _mediaBox.addAll(mediaList);

        final scanDir = CommonHelper.getParentFolders(
          mediaList.map((e) => e.data).toList(),
        );

        _settingsBox.put(CacheKey.Settings.scanDir, scanDir);

        // final executor = Executor(concurrency: 100);
        //
        // for (var audio in audios) {
        //   executor.scheduleTask(() async {
        //     await _artworkColorBox.put(
        //       audio.id,
        //       ArtworkColorEntity(
        //         primary: audio.color != null ? audio.color!.primaryColor! : -1,
        //         secondary: audio.color != null
        //             ? audio.color!.secondaryColor!
        //             : -1,
        //         isDark: audio.color != null ? audio.color!.isDark! : false,
        //       ),
        //     );
        //   });
        // }
        //
        // await executor.join(withWaiting: true);
        //
        // await executor.close();
      },
    );
  }
}
