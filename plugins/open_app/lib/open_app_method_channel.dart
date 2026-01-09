import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'open_app_platform_interface.dart';

/// An implementation of [OpenAppPlatform] that uses method channels.
class MethodChannelOpenApp extends OpenAppPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('open_app');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
        'getPlatformVersion');
    return version;
  }

  @override
  Future<bool?> openApp(
      {required String appId, Map<String, String>? extras}) async {
    var result = await methodChannel.invokeMethod<bool>(
        'openApp', {"appId": appId, "extras": extras});
    return result;
  }

  @override
  Future<bool?> openMarket(
      {required String appId, Map<String, String>? extras}) async {
    var result = await methodChannel.invokeMethod<bool>(
        'openMarket', {"appId": appId, "extras": extras});
    return result;
  }

  @override
  Future<bool?> openActivity(
      {required String appId, required String activity, Map<String,
          String>? extras }) async {
    var result = await methodChannel.invokeMethod<bool>(
        'openActivity',
        {"appId": appId, "activity": activity, "extras": extras});
    return result;
  }
}
