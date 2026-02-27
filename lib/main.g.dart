part of 'main.dart';

late final EffectCleanup _brightnessThemeListener;

final _settingsBox = Hive.box(BoxKey.settings);

Future<void> initHive() async {
  final dir = await CommonHelper().getAppDataDir();

  await Hive.initFlutter(path.join(dir.path, 'hive'));

  Hive.registerAdapter(MediaEntityAdapter(), override: true);
  Hive.registerAdapter(MediaOrderEntityAdapter(), override: true);

  await Hive.openBox(BoxKey.media);

  await Hive.openBox(BoxKey.settings);

  await Hive.openBox(BoxKey.liked);

  await Hive.openBox(BoxKey.mediaCount);

  await Hive.openBox(BoxKey.mediaOrder);
}

void setDisplayMode() {
  if (Platform.isAndroid) {
    FlutterDisplayMode.supported.then((value) {
      final List<DisplayMode> modes = value;

      final _displayMode = _settingsBox.get(
        CacheKey.Settings.displayMode,
        defaultValue: null,
      );

      DisplayMode? displayMode;

      if (_displayMode != null) {
        displayMode = modes.firstWhere((e) => e.toString() == _displayMode);
      }

      displayMode ??= DisplayMode.auto;
      FlutterDisplayMode.setPreferredMode(displayMode);

      _settingsBox.put(CacheKey.Settings.displayMode, displayMode.toString());
    });
  }
}

Future<void> initDesktop() async {
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: const Size(1600, 900),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

Future<void> initServices() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  GestureBinding.instance.resamplingEnabled = true;

  if (PlatformHelper.isDesktop) {
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

  FlutterNativeSplash.remove();

  Request();

  ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
    debugPrint(flutterErrorDetails.toString());
    return Material(
      child: Center(
        child: Text(
          "发生未预见的错误\n请通知开发者"
          "${flutterErrorDetails.exceptionAsString()}",
          textAlign: TextAlign.center,
        ),
      ),
    );
  };
}

Future<Map<String, Catcher2Options>> initCatcher() async {
  // 异常捕获 logo记录
  final customParameters = {
    'BuildConfig':
        '\nBuild Time: ${DateUtil.formatDateMs(BuildConfig.buildTime * 1000, isUtc: true, format: DateFormats.full)}\n'
        'Commit Hash: ${BuildConfig.commitHash}',
  };
  final fileHandler = await JsonFileHandler.init();
  final Catcher2Options debugConfig = Catcher2Options(SilentReportMode(), [
    ?fileHandler,
    ConsoleHandler(
      enableDeviceParameters: false,
      enableApplicationParameters: false,
      enableCustomParameters: true,
    ),
  ], customParameters: customParameters);

  final Catcher2Options releaseConfig = Catcher2Options(SilentReportMode(), [
    ?fileHandler,
    ConsoleHandler(enableCustomParameters: true),
  ], customParameters: customParameters);

  return {"debugConfig": debugConfig, "releaseConfig": releaseConfig};
}

void _didChangePlatformBrightness() {
  if (settingsManager.brightnessTheme.value != BrightnessTheme.system) {
    return;
  }

  final newBrightness = PlatformDispatcher.instance.platformBrightness;

  appState.brightness.value = newBrightness;

  _settingsBox.put(CacheKey.Settings.brightness, newBrightness.index);

  homeController.setStatusBarIconBrightness(newBrightness == Brightness.dark);
}

void precacheAssets(BuildContext context) {
  // precacheImage(AssetImage("assets/images/no_cover.png"), context);
  // precacheImage(AssetImage("assets/images/hires.png"), context);
  // precacheImage(AssetImage("assets/images/hq.png"), context);
  // precacheImage(AssetImage("assets/images/hr.png"), context);
  // precacheImage(AssetImage("assets/images/sq.png"), context);
  // precacheImage(AssetImage("assets/images/lossless.png"), context);
  // precacheImage(AssetImage("assets/images/no_cover.png"), context);
  // precacheImage(AssetImage("assets/images/no_cover_dark.png"), context);
}
