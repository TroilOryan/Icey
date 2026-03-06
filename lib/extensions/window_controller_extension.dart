import 'package:IceyPlayer/components/play_lyric/desktop_lyric/desktop_lyric.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

extension WindowControllerExtension on WindowController {
  Future<void> desktopLyricWindowInit() async {
    return await setWindowMethodHandler((call) async {
      switch (call.method) {
        case "close":
          return await windowManager.close();
        case "update_lyric":
          final raw = call.arguments as Map;
          final map = Map<String, dynamic>.from(raw);

          lyric.value = map["lyric"];
          break;
        default:
          throw MissingPluginException('Not implemented: ${call.method}');
      }
    });
  }

  Future<void> mainWindowInit() async {
    return await setWindowMethodHandler((call) async {
      switch (call.method) {
        case "hide_desktop_lyric":
          break;
        default:
          throw MissingPluginException('Not implemented: ${call.method}');
      }
    });
  }

  Future<void> updateLyric(String value) {
    return invokeMethod("update_lyric", {"lyric": value});
  }
}
