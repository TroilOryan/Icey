import 'package:flutter_test/flutter_test.dart';
import 'package:audio_query/audio_query.dart';
import 'package:audio_query/audio_query_platform_interface.dart';
import 'package:audio_query/audio_query_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAudioQueryPlatform
    with MockPlatformInterfaceMixin
    implements AudioQueryPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AudioQueryPlatform initialPlatform = AudioQueryPlatform.instance;

  test('$MethodChannelAudioQuery is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAudioQuery>());
  });

  test('getPlatformVersion', () async {
    AudioQuery audioQueryPlugin = AudioQuery();
    MockAudioQueryPlatform fakePlatform = MockAudioQueryPlatform();
    AudioQueryPlatform.instance = fakePlatform;

    expect(await audioQueryPlugin.getPlatformVersion(), '42');
  });
}
