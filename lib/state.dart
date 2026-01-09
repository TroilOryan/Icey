part of 'main.dart';

class AppState {
  final Signal<Brightness?> statusBarIconBrightness = signal(null);

  final Signal<Brightness> brightness = signal(
    Brightness.values[_settingsBox.get(
      CacheKey.Settings.brightness,
      defaultValue: Brightness.light.index,
    )],
  );
}
