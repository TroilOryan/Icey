import "dart:async";

import "package:IceyPlayer/helpers/toast/toast.dart";
import "package:device_info_plus/device_info_plus.dart";
import "package:permission_handler/permission_handler.dart";

Future<bool> requestPermissions() async {
  final deviceInfo = await DeviceInfoPlugin().androidInfo;
  if (deviceInfo.version.sdkInt >= 33) {
    // Android 13+
    final permission = await Permission.audio.request();
    if (permission.isPermanentlyDenied) {
      showToast("请打开音频读取权限");

      Timer(const Duration(seconds: 1), () {
        openAppSettings();
      });
      return false;
    }

    return permission.isGranted;
  } else if (deviceInfo.version.sdkInt >= 29) {
    // Android 10+
    final permission = await Permission.storage.request();
    if (permission.isPermanentlyDenied) {
      showToast("请打开音频读取权限");

      Timer(const Duration(seconds: 1), () {
        openAppSettings();
      });

      return false;
    }

    return permission.isGranted;
  } else {
    // Android 9及以下
    return await Permission.storage.request().isGranted;
  }
}
