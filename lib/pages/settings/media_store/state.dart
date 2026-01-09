part of 'page.dart';

class MediaStoreState {
  final filterShort = signal(
    _settingsBox.get(CacheKey.Settings.filterShort, defaultValue: true),
  );

  final Signal<List<String>> scanDir = signal(
    _settingsBox.get(CacheKey.Settings.scanDir, defaultValue: <String>[]),
  );

  final Signal<List<String>> filterDir = signal(
    _settingsBox.get(CacheKey.Settings.filterDir, defaultValue: <String>[]),
  );
}
