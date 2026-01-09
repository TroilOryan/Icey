import 'package:audio_query/types/artwork_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_query_platform_interface.dart';
import 'entities.dart';

/// An implementation of [AudioQueryPlatform] that uses method channels.
class MethodChannelAudioQuery extends AudioQueryPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('audio_query');

  @override
  Future queryAudios() async {
    final audios = await methodChannel.invokeMethod('queryAudios');

    return audios;
  }

  @override
  Future<bool> deleteMediaFile(String filePath) async {
    final status = await methodChannel.invokeMethod('deleteMediaFile', {
      "filePath": filePath,
    });

    return status;
  }

  @override
  Future<bool> deleteMediaFolder(String folderPath) async {
    final status = await methodChannel.invokeMethod('deleteMediaFolder', {
      "filePath": folderPath,
    });

    return status;
  }

  @override
  Future queryArtworkColor(Uint8List data, String cacheKey) async {
    final res = await methodChannel.invokeMethod('queryArtworkColor', {
      "data": data,
      "cacheKey": cacheKey,
    });

    return res;
  }

  @override
  Future<Uint8List?> queryArtwork(
    int id,
    ArtworkType type, {
    ArtworkFormat? format,
    int? size,
    int? quality,
  }) async {
    return await methodChannel.invokeMethod('queryArtwork', {
      "id": id,
      "type": type.index,
      "format": format != null ? format.index : ArtworkFormat.JPEG.index,
      "size": size ?? 200,
      "quality": (quality != null && quality <= 100) ? quality : 50,
    });
  }
}
