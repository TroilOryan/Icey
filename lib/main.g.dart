part of 'main.dart';

late final EffectCleanup _brightnessThemeListener;

final _settingsBox = Hive.box(BoxKey.settings);

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
  final listBg = _settingsBox.get(CacheKey.Settings.listBg, defaultValue: null);

  if (listBg != null) {
    precacheImage(MemoryImage(listBg), context);
  }

  precacheImage(AssetImage("assets/images/no_cover.png"), context);
  precacheImage(AssetImage("assets/images/hires.png"), context);
  precacheImage(AssetImage("assets/images/hq.png"), context);
  precacheImage(AssetImage("assets/images/hr.png"), context);
  precacheImage(AssetImage("assets/images/sq.png"), context);
  precacheImage(AssetImage("assets/images/lossless.png"), context);
  precacheImage(AssetImage("assets/images/no_cover_dark.png"), context);
}
