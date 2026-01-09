import 'open_app_platform_interface.dart';

class OpenApp {
  Future<String?> getPlatformVersion() {
    return OpenAppPlatform.instance.getPlatformVersion();
  }

  Future<bool?> openApp({required String appId, Map<String, String>? extras}) {
    return OpenAppPlatform.instance.openApp(appId: appId, extras: extras);
  }

  Future<bool?> openMarket({
    required String appId,
    Map<String, String>? extras,
  }) {
    return OpenAppPlatform.instance.openMarket(appId: appId, extras: extras);
  }

  Future<bool?> openActivity({
    required String appId,
    required String activity,
    Map<String, String>? extras,
  }) {
    return OpenAppPlatform.instance.openActivity(
      appId: appId,
      activity: activity,
      extras: extras,
    );
  }
}
