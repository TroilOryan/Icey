part of 'main.dart';

class AppController {
  final state = AppState();

  final _settingsBox = Hive.box(BoxKey.settings);

  late final EffectCleanup _brightnessThemeListener;

  late final EffectCleanup _immersiveListener;

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

  Future<Map<String, dynamic>> initServices() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    GestureBinding.instance.resamplingEnabled = true;

    await initHive();

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

    // 异常捕获 logo记录
    final customParameters = {
      'BuildConfig':
          '\nBuild Time: ${DateUtil.formatDateMs(BuildConfig.buildTime, format: DateFormats.full)}\n'
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

  void didChangePlatformBrightness() {
    if (settingsManager.brightnessTheme.value != BrightnessTheme.system) {
      return;
    }

    final newBrightness = PlatformDispatcher.instance.platformBrightness;

    state.brightness.value = newBrightness;

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

  void onInit(BuildContext context) {
    precacheAssets(context);

    GoTransition.defaultCurve = Curves.easeInOutSine;
    GoTransition.defaultDuration = const Duration(milliseconds: 600);

    setDisplayMode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _brightnessThemeListener = effect(() {
        if (settingsManager.brightnessTheme.value == BrightnessTheme.system) {
          state.brightness.value = MediaQuery.of(context).platformBrightness;
        } else if (settingsManager.brightnessTheme.value ==
            BrightnessTheme.light) {
          state.brightness.value = Brightness.light;
        } else {
          state.brightness.value = Brightness.dark;
        }
      });

      _immersiveListener = effect(() {
        SystemChrome.setEnabledSystemUIMode(
          settingsManager.immersive.value
              ? SystemUiMode.immersive
              : SystemUiMode.edgeToEdge,
        );
      });
    });
  }

  void onDispose() {
    _brightnessThemeListener();
  }
}
