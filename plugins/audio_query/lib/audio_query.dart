import 'dart:async';
import 'dart:typed_data';

import 'package:audio_query/audio_progress_stream.dart';
import 'package:audio_query/entities.dart';

import 'audio_query_platform_interface.dart';
import 'types/artwork_type.dart';

class AudioQuery {
  Future<Stream<List<AudioEntity>>> queryAudios() async {
    StreamController<List<AudioEntity>> streamController = StreamController();
    final List<AudioEntity> audios = [];

    AudioProgressStream.progressStream.listen(
      (event) {
        switch (event['type']) {
          case 'data':
            audios.add(AudioEntity(event["data"]));
            streamController.add(audios);
            break;
          case 'complete':
            streamController.close();
            break;
        }
      },
      onError: (error) => print('错误: $error'),
      onDone: () {},
    );

    AudioQueryPlatform.instance.queryAudios();

    return streamController.stream;
  }

  Future<bool> deleteMediaFile(String filePath) async {
    final status = await AudioQueryPlatform.instance.deleteMediaFile(filePath);

    return status;
  }

  Future<bool> deleteMediaFolder(String folderPath) async {
    final status = await AudioQueryPlatform.instance.deleteMediaFolder(
      folderPath,
    );

    return status;
  }

  Future<Map<String, dynamic>>? queryArtworkWithColor(
    String id,
    ArtworkType type, {
    ArtworkFormat? format,
    int? size,
    int? quality,
  }) async {
    final res = await AudioQueryPlatform.instance.queryArtworkWithColor(
      id,
      type,
      format: format,
      size: size,
      quality: quality,
    );

    return {
      "cover": res["data"],
      "primaryColor": res["color"]["primaryColor"],
      "secondaryColor": res["color"]["secondaryColor"],
      "isDark": res["color"]["isDark"],
    };
  }

  Future<Uint8List?> queryArtwork(
    String id,
    ArtworkType type, {
    ArtworkFormat? format,
    int? size,
    int? quality,
  }) async {
    final res = await AudioQueryPlatform.instance.queryArtwork(
      id,
      type,
      format: format,
      size: size,
      quality: quality,
    );

    return res;
  }
}
