import 'dart:io';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:window_manager/window_manager.dart';
import '../src/rust/frb_generated.dart';
import '../helpers/platform.dart';
import '../helpers/common.dart';
import '../helpers/media/media.dart';
import '../services/audio_service.dart';
import '../http/init.dart';
import 'hive.dart';
import 'desktop.dart';

Future<void> initServices() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await LiquidGlassWidgets.initialize();

  CommonHelper.tmpDir = await getApplicationDocumentsDirectory();

  if (PlatformHelper.isMobile) {
    GestureBinding.instance.resamplingEnabled = true;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  if (PlatformHelper.isDesktop) {
    await windowManager.ensureInitialized();

    await initDesktop();
  }

  await RustLib.init();

  await initHive();

  final medias = MediaHelper.queryLocalMedia(init: true);

  final audioServiceHandler = AudioServiceHandler();

  final audioService = await AudioService.init(
    builder: () => audioServiceHandler,
    config: const AudioServiceConfig(
      androidNotificationChannelId: "com.IceyPlayer.channel.audio",
      androidNotificationChannelName: "Audio playback",
      androidNotificationChannelDescription: 'Media Playback',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
      androidStopForegroundOnPause: true,
    ),
  );

  mediaManager.init(medias: medias, audioService: audioService);

  Request();

  ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
    debugPrint(flutterErrorDetails.toString());

    return Material(
      child: Center(
        child: Text(
          "发生未预见的错误\n请通知开发者"
          "${flutterErrorDetails.exceptionAsString()}",
          textAlign: .center,
        ),
      ),
    );
  };
}
