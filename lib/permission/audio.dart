import "dart:async";
import "package:IceyPlayer/helpers/toast/toast.dart";
import "package:device_info_plus/device_info_plus.dart";
import "package:permission_handler/permission_handler.dart";

Future<bool> requestPermissions() async {
  final deviceInfo = await DeviceInfoPlugin().androidInfo;

  if (deviceInfo.version.sdkInt >= 33) {
    // Android 13+ - 使用细化音频权限
    return await _handlePermissionRequest(Permission.audio);
  } else if (deviceInfo.version.sdkInt >= 29) {
    // Android 10-12 - 使用存储权限
    return await _handlePermissionRequest(Permission.storage);
  } else {
    // Android 9及以下 - 使用存储权限（包含读写）
    return await _handlePermissionRequest(Permission.storage);
  }
}

/// 统一的权限请求处理方法
Future<bool> _handlePermissionRequest(Permission permission) async {
  final status = await permission.request();

  if (status.isPermanentlyDenied) {
    // 永久拒绝：引导用户到设置页面
    showToast("请打开音频读取权限");
    Timer(const Duration(seconds: 1), () {
      openAppSettings();
    });
    return false;
  } else if (status.isDenied) {
    // 临时拒绝：稍后可以再次请求
    return false;
  }

  // 已授权
  return status.isGranted;
}
