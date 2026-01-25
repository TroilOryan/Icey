class CacheKey {
  static _SearchKeys Search = _SearchKeys();

  static _SettingsKeys Settings = _SettingsKeys();
}

class _SearchKeys {
  /// 搜索歌单歌曲历史
  final String history = "search_history";
}

class _SettingsKeys {
  /// 帧率
  final String displayMode = "settings_displayMode";

  /// 当前歌曲
  final String currentMedia = "settings_currentMedia";

  /// 播放进度
  final String currentPosition = 'settings_currentPosition';

  /// 播放模式
  final String playMode = "settings_playMode";

  /// 主题色
  final String themeColor = "settings_themeColor";

  /// 排序方式
  final String sortType = "settings_sortType";

  /// 深浅色模式
  final String brightnessTheme = "settings_brightnessTheme";

  final String listType = "settings_listType";

  final String brightness = "settings_brightness";

  final String liquidGlass = "settings_liquidGlass";

  final String scrollHidePlayBar = "settings_scrollHidePlayBar";

  final String isMaterialScrollBehavior = "settings_isMaterialScrollBehavior";

  /// 封面样式
  final String coverShape = "settings_coverShape";

  final String artCover = "settings_artCover";

  /// 当前主题色
  final String color = "settings_color";

  final String light = "settings_light";

  final String dark = "settings_dark";

  final String filterShort = "settings_filter_short";

  final String scanDir = "settings_scan_dir";

  final String filterDir = "settings_filter_dir";

  final String wakelock = "settings_wake_lock";

  final String dynamicLight = "settings_dynamic_light";

  final String highMaterial = "settings_high_material";

  final String karaoke = "settings_karaoke";

  final String fakeEnhanced = "settings_fake_enhanced";

  final String panelOpened = "settings_panel_opened";

  final String listBg = "settings_list_bg";

  final String pro = "settings_pro";

  final String immersive = "settings_immersive";

  final String audioFocus = "settings_audioFocus";

  /// 启动检查更新
  final String autoUpdate = "settings_autoUpdate";
}
