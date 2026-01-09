part of 'page.dart';

final _settingsBox = Boxes.settingsBox;

final state = MediaStoreState();

void setFilterShort(bool value) {
  state.filterShort.value = value;

  _settingsBox.put(CacheKey.Settings.filterShort, value);
}

void setScanDir(List<String> value) {
  state.scanDir.value = value;

  _settingsBox.put(CacheKey.Settings.scanDir, value);
}

void setFilterDir(List<String> value) {
  state.filterDir.value = value;

  _settingsBox.put(CacheKey.Settings.filterDir, value);
}

void handleSwitchScanDirStatus(String dir) {
  final filterDirRes = [...state.filterDir.value, dir];

  final scanDirRes = state.scanDir.value..remove(dir);

  state.filterDir.value = filterDirRes;

  state.scanDir.value = scanDirRes;

  _settingsBox.put(CacheKey.Settings.scanDir, scanDirRes);
  _settingsBox.put(CacheKey.Settings.filterDir, filterDirRes);

  List<MediaEntity> mediaList = mediaManager.mediaList.value.where((media) {
    final isFiltered = filterDirRes.contains(path.dirname(media.data));

    return !isFiltered;
  }).toList();

  mediaManager.setLocalMediaList(mediaList);
}

void handleSwitchFilterDirStatus(String dir) {
  final scanDirRes = [...state.scanDir.value, dir];

  final filterDirRes = state.filterDir.value..remove(dir);

  state.filterDir.value = filterDirRes;

  state.scanDir.value = scanDirRes;

  _settingsBox.put(CacheKey.Settings.scanDir, scanDirRes);
  _settingsBox.put(CacheKey.Settings.filterDir, filterDirRes);

  List<MediaEntity> mediaList = mediaManager.localMediaList.value.where((
    media,
  ) {
    final isFiltered = filterDirRes.contains(path.dirname(media.data));

    return !isFiltered;
  }).toList();

  mediaManager.setLocalMediaList(mediaList);
}
