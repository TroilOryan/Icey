
import 'dart:io';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';

Future<void> initDesktop() async {
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1600, 900),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setMinimumSize(
      Platform.isLinux
          ? const Size(1102, 752)
          : Platform.isWindows
          ? const Size(1050 + 16, 700 + 9)
          : const Size(1050, 700),
    );
  });

  trayManager.setIcon(
    Platform.isWindows
        ? 'assets/images/desktop_icon.ico'
        : 'assets/images/desktop_icon.png',
  );

  trayManager.setToolTip("Icey Player");

  Menu menu = Menu(
    items: [
      MenuItem(key: 'show', label: '显示'),
      MenuItem.separator(),
      MenuItem(key: 'exit', label: '退出'),
    ],
  );

  trayManager.setContextMenu(menu);
}
