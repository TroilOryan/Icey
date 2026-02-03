part of 'main.dart';

Future<void> initHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(MediaEntityAdapter(), override: true);
  Hive.registerAdapter(MediaOrderEntityAdapter(), override: true);

  await Hive.openBox(BoxKey.media);

  await Hive.openBox(BoxKey.settings);

  Hive.openBox(BoxKey.liked);

  Hive.openBox(BoxKey.mediaCount);

  Hive.openBox(BoxKey.mediaOrder);
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
    size: Size(400, 600),
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

  await initHive();

  if (PlatformHelper.isDesktop) {
    await initDesktop();
  }

  final medias = MediaHelper.queryLocalMedia(init: true);

  final audioPlayerHandler = AudioPlayerHandler();

  final audioService = await AudioService.init(
    builder: () => audioPlayerHandler,
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

late final EffectCleanup _brightnessThemeListener;

final _settingsBox = Hive.box(BoxKey.settings);

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
