import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'audio_query_method_channel.dart';
import 'types/artwork_type.dart';

abstract class AudioQueryPlatform extends PlatformInterface {
  /// Constructs a AudioQueryPlatform.
  AudioQueryPlatform() : super(token: _token);

  static final Object _token = Object();

  static AudioQueryPlatform _instance = MethodChannelAudioQuery();

  /// The default instance of [AudioQueryPlatform] to use.
  ///
  /// Defaults to [MethodChannelAudioQuery].
  static AudioQueryPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AudioQueryPlatform] when
  /// they register themselves.
  static set instance(AudioQueryPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future queryAudios() {
    throw UnimplementedError('queryAudios() has not been implemented.');
  }

  Future<bool> deleteMediaFile(String filePath) {
    throw UnimplementedError('deleteMediaFile() has not been implemented.');
  }

  Future<bool> deleteMediaFolder(String folderPath) {
    throw UnimplementedError('deleteMediaFolder() has not been implemented.');
  }

  Future queryArtworkWithColor(
    String id,
    ArtworkType type, {
    ArtworkFormat? format,
    int? size,
    int? quality,
  }) {
    throw UnimplementedError(
      'queryArtworkWithColor() has not been implemented.',
    );
  }

  Future<Uint8List?> queryArtwork(
    String id,
    ArtworkType type, {
    ArtworkFormat? format,
    int? size,
    int? quality,
  }) {
    throw UnimplementedError('queryArtwork() has not been implemented.');
  }
}
