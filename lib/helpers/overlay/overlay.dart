import 'dart:io';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayHelper {
  static Future<bool> isPermissionGranted() async {
    if (!Platform.isAndroid) {
      return false;
    }

    return await FlutterOverlayWindow.isPermissionGranted();
  }

  static Future<bool?> requestPermission() async {
    if (!Platform.isAndroid) {
      return false;
    }

    return await FlutterOverlayWindow.requestPermission();
  }

  static Future<bool> isActive() async {
    if (!Platform.isAndroid) {
      return false;
    }

    return await FlutterOverlayWindow.isActive();
  }

  static Future<void> showOverlay({
    int height = WindowSize.fullCover,
    int width = WindowSize.matchParent,
    OverlayAlignment alignment = OverlayAlignment.center,
    NotificationVisibility visibility = NotificationVisibility.visibilitySecret,
    OverlayFlag flag = OverlayFlag.defaultFlag,
    String overlayTitle = "overlay activated",
    String? overlayContent,
    bool enableDrag = false,
    PositionGravity positionGravity = PositionGravity.none,
    OverlayPosition? startPosition,
  }) async {
    if (!Platform.isAndroid) {
      return;
    }

    await FlutterOverlayWindow.showOverlay(
      height: height,
      width: width,
      alignment: alignment,
      visibility: visibility,
      flag: flag,
      overlayTitle: overlayTitle,
      overlayContent: overlayContent,
      enableDrag: enableDrag,
      positionGravity: positionGravity,
      startPosition: startPosition,
    );
  }

  static Future<void> closeOverlay() async {
    if (!Platform.isAndroid) {
      return;
    }

    await FlutterOverlayWindow.closeOverlay();
  }

  static Future<void> moveOverlay(OverlayPosition position) async {
    if (!Platform.isAndroid) {
      return;
    }

    await FlutterOverlayWindow.moveOverlay(position);
  }

  static Future<void> shareData(dynamic data) async {
    if (!Platform.isAndroid) {
      return;
    }

    await FlutterOverlayWindow.shareData(data);
  }

  static void disposeOverlayListener() {
    if (!Platform.isAndroid) {
      return;
    }

    FlutterOverlayWindow.disposeOverlayListener();
  }

  static Stream<dynamic>? overlayListener = Platform.isAndroid
      ? FlutterOverlayWindow.overlayListener
      : null;
}
