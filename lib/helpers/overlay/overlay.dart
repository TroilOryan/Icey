import 'dart:io';

import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/constants/cache_key.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

final _settingsBox = Boxes.settingsBox;

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

  static Future<void> showLyricOverlay() async {
    if (!await OverlayHelper.isActive()) {
      await OverlayHelper._showOverlay(
        enableDrag: false,
        overlayTitle: "Icey Player",
        overlayContent: 'Overlay Lyric',
        flag: OverlayFlag.clickThrough,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.auto,
        height: WindowSize.matchParent,
        width: WindowSize.matchParent,
        startPosition: const OverlayPosition(0, 0),
      );

      await OverlayHelper.moveOverlay(
        OverlayPosition(
          _settingsBox.get(CacheKey.Settings.overlayLyricX, defaultValue: 0.0),
          _settingsBox.get(CacheKey.Settings.overlayLyricY, defaultValue: 0.0),
        ),
      );
    }
  }

  static Future<void> _showOverlay({
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
    if (Platform.isAndroid) {
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
  }

  static Future<void> closeOverlay() async {
    if (Platform.isAndroid) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }

  static Future<void> moveOverlay(OverlayPosition position) async {
    if (Platform.isAndroid) {
      await FlutterOverlayWindow.moveOverlay(position);
    }
  }

  static Future<void> shareData(dynamic data) async {
    if (Platform.isAndroid) {
      await FlutterOverlayWindow.shareData(data);
    }
  }

  static void disposeOverlayListener() {
    if (Platform.isAndroid) {
      FlutterOverlayWindow.disposeOverlayListener();
    }
  }

  static Stream<dynamic>? overlayListener = Platform.isAndroid
      ? FlutterOverlayWindow.overlayListener
      : null;
}
