import 'package:flutter_test/flutter_test.dart';
import 'package:open_app/open_app.dart';
import 'package:open_app/open_app_platform_interface.dart';
import 'package:open_app/open_app_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockOpenAppPlatform
    with MockPlatformInterfaceMixin
    implements OpenAppPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final OpenAppPlatform initialPlatform = OpenAppPlatform.instance;

  test('$MethodChannelOpenApp is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelOpenApp>());
  });

  test('getPlatformVersion', () async {
    OpenApp openAppPlugin = OpenApp();
    MockOpenAppPlatform fakePlatform = MockOpenAppPlatform();
    OpenAppPlatform.instance = fakePlatform;

    expect(await openAppPlugin.getPlatformVersion(), '42');
  });
}
