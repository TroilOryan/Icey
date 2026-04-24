import 'dart:typed_data';

import 'package:IceyPlayer/helpers/overlay/overlay.dart';
import 'package:IceyPlayer/helpers/toast/toast.dart';
import 'package:IceyPlayer/models/lyric/lyric.dart';
import 'package:flutter/services.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/constants/cache_key.dart';
import 'package:IceyPlayer/helpers/media/media.dart';
import 'package:IceyPlayer/helpers/media_scanner/media_sort.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:signals/signals.dart';

final settingsManager = SettingsManager();

final _settingsBox = Boxes.settingsBox;

enum CoverShape {
  immersive(value: 1, name: "沉浸封面"),
  circle(value: 2, name: "圆形封面"),
  rectangle(value: 3, name: "方形封面"),
  irregular(value: 4, name: "不规则封面");

  const CoverShape({required this.value, required this.name});

  final int value;
  final String name;

  static CoverShape getByValue(int value) {
    return values.firstWhere((element) => element.value == value);
  }

  static CoverShape getByName(String value) {
    return values.firstWhere((element) => element.name == value);
  }
}

enum BrightnessTheme {
  system(
    value: 'system',
    name: "跟随系统",
    icon: SFIcons.sf_eye,
    activeIcon: SFIcons.sf_eye_fill,
  ),
  light(
    value: 'light',
    name: "浅色模式",
    icon: SFIcons.sf_sun_max,
    activeIcon: SFIcons.sf_sun_max_fill,
  ),
  dark(
    value: 'dark',
    name: "深色模式",
    icon: SFIcons.sf_moon,
    activeIcon: SFIcons.sf_moon_fill,
  );

  const BrightnessTheme({
    required this.value,
    required this.name,
    required this.icon,
    required this.activeIcon,
  });

  final String value;
  final String name;
  final IconData icon;
  final IconData activeIcon;

  static BrightnessTheme getByValue(String value) {
    return values.firstWhere((element) => element.value == value);
  }

  static BrightnessTheme getByName(String value) {
    return values.firstWhere((element) => element.name == value);
  }

  static ThemeMode toThemeMode(String value) {
    return ThemeMode.values.firstWhere((element) => element.name == value);
  }
}

class SettingsManager {
  final Signal<MediaSort> _sortType;
  final Signal<BrightnessTheme> _brightnessTheme;
  final Signal<bool> _liquidGlass;
  final Signal<bool> _isMaterialScrollBehavior;
  final Signal<bool> _scrollHidePlayBar;
  final Signal<CoverShape> _coverShape;
  final Signal<bool> _artCover;
  final Signal<bool> _wakelock;
  final Signal<bool> _dynamicLight;
  final Signal<Uint8List> _listBg;
  final Signal<bool> _highMaterial;
  final Signal<bool> _karaoke;
  final Signal<bool> _fakeEnhanced;
  final Signal<bool> _lyricOverlay;
  final Signal<bool> _immersive;
  final Signal<bool> _concert;
  final Signal<bool> _audioFocus;
  final Signal<bool> _autoUpdate;

  Signal<MediaSort> get sortType => _sortType;

  Signal<BrightnessTheme> get brightnessTheme => _brightnessTheme;

  Signal<bool> get liquidGlass => _liquidGlass;

  Signal<bool> get isMaterialScrollBehavior => _isMaterialScrollBehavior;

  Signal<bool> get scrollHidePlayBar => _scrollHidePlayBar;

  Signal<CoverShape> get coverShape => _coverShape;

  Signal<bool> get artCover => _artCover;

  Signal<bool> get wakelock => _wakelock;

  Signal<bool> get dynamicLight => _dynamicLight;

  Signal<Uint8List> get listBg => _listBg;

  Signal<bool> get highMaterial => _highMaterial;

  Signal<bool> get karaoke => _karaoke;

  Signal<bool> get fakeEnhanced => _fakeEnhanced;

  Signal<bool> get lyricOverlay => _lyricOverlay;

  Signal<bool> get immersive => _immersive;

  Signal<bool> get concert => _concert;

  Signal<bool> get audioFocus => _audioFocus;

  Signal<bool> get autoUpdate => _autoUpdate;

  static T _loadSetting<T>(String key, T defaultValue) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  static T _loadSettingAs<T, R>(String key, R defaultValue, T Function(R) fromBox) {
    return fromBox(_settingsBox.get(key, defaultValue: defaultValue));
  }

  static void _saveSetting<T>(String key, T value, [dynamic Function(T)? toBox]) {
    _settingsBox.put(key, toBox != null ? toBox(value) : value);
  }

  SettingsManager()
    : _sortType = signal(MediaSort.title),
      _brightnessTheme = signal(BrightnessTheme.system),
      _liquidGlass = signal(true),
      _scrollHidePlayBar = signal(true),
      _isMaterialScrollBehavior = signal(false),
      _coverShape = signal(CoverShape.circle),
      _artCover = signal(true),
      _wakelock = signal(false),
      _dynamicLight = signal(true),
      _listBg = signal(Uint8List(0)),
      _highMaterial = signal(true),
      _karaoke = signal(true),
      _fakeEnhanced = signal(false),
      _lyricOverlay = signal(false),
      _immersive = signal(false),
      _concert = signal(false),
      _audioFocus = signal(true),
      _autoUpdate = signal(true) {
    _sortType.value = _loadSettingAs(
      CacheKey.Settings.sortType,
      MediaSort.title.value,
      MediaSort.getByValue,
    );
    _brightnessTheme.value = _loadSettingAs(
      CacheKey.Settings.brightnessTheme,
      BrightnessTheme.system.value,
      BrightnessTheme.getByValue,
    );
    _liquidGlass.value = _loadSetting(CacheKey.Settings.liquidGlass, true);
    _scrollHidePlayBar.value = _loadSetting(CacheKey.Settings.scrollHidePlayBar, true);
    _isMaterialScrollBehavior.value = _loadSetting(CacheKey.Settings.isMaterialScrollBehavior, false);
    _coverShape.value = _loadSettingAs(
      CacheKey.Settings.coverShape,
      CoverShape.circle.value,
      CoverShape.getByValue,
    );
    _artCover.value = _loadSetting(CacheKey.Settings.artCover, true);
    _wakelock.value = _loadSetting(CacheKey.Settings.wakelock, true);
    _dynamicLight.value = _loadSetting(CacheKey.Settings.dynamicLight, false);
    _listBg.value = _loadSetting(CacheKey.Settings.listBg, Uint8List(0));
    _highMaterial.value = _loadSetting(CacheKey.Settings.highMaterial, true);
    _fakeEnhanced.value = _loadSetting(CacheKey.Settings.fakeEnhanced, false);
    setLyricOverlay(_loadSetting(CacheKey.Settings.lyricOverlay, false));
    _immersive.value = _loadSetting(CacheKey.Settings.immersive, false);
    _concert.value = _loadSetting(CacheKey.Settings.concert, false);
    _audioFocus.value = _loadSetting(CacheKey.Settings.audioFocus, true);
    _autoUpdate.value = _loadSetting(CacheKey.Settings.autoUpdate, true);
  }

  void setSortType(MediaSort value) {
    _sortType.value = value;

    _saveSetting(CacheKey.Settings.sortType, value, (v) => v.value);

    MediaHelper.queryLocalMedia();
  }

  void setBrightnessTheme(BrightnessTheme value) {
    _brightnessTheme.value = value;

    _saveSetting(CacheKey.Settings.brightnessTheme, value, (v) => v.value);
  }

  void setLiquidGlass(bool value) {
    _liquidGlass.value = value;

    _saveSetting(CacheKey.Settings.liquidGlass, value);
  }

  void setScrollHidePlayBar(bool value) {
    _scrollHidePlayBar.value = value;

    _saveSetting(CacheKey.Settings.scrollHidePlayBar, value);
  }

  void setIsMaterialScrollBehavior(bool value) {
    _isMaterialScrollBehavior.value = value;

    _saveSetting(CacheKey.Settings.isMaterialScrollBehavior, value);
  }

  void setCoverShape(CoverShape value) {
    _coverShape.value = value;

    _saveSetting(CacheKey.Settings.coverShape, value, (v) => v.value);
  }

  void setArtCover(bool value) {
    _artCover.value = value;

    _saveSetting(CacheKey.Settings.artCover, value);
  }

  void setWakelock(bool value) {
    _wakelock.value = value;

    _saveSetting(CacheKey.Settings.wakelock, value);
  }

  void setDynamicLight(bool value) {
    _dynamicLight.value = value;

    _saveSetting(CacheKey.Settings.dynamicLight, value);
  }

  void setListBg(Uint8List value) {
    _listBg.value = value;

    _saveSetting(CacheKey.Settings.listBg, value);
  }

  void setHighMaterial(bool value) {
    _highMaterial.value = value;

    _saveSetting(CacheKey.Settings.highMaterial, value);
  }

  void setKaraoke(bool value) {
    _karaoke.value = value;

    _saveSetting(CacheKey.Settings.karaoke, value);
  }

  void setFakeEnhanced(bool value) {
    _fakeEnhanced.value = value;

    _saveSetting(CacheKey.Settings.fakeEnhanced, value);
  }

  Future<void> setLyricOverlay(bool value) async {
    _lyricOverlay.value = value;

    _saveSetting(CacheKey.Settings.lyricOverlay, value);

    if (value) {
      final res = await OverlayHelper.isPermissionGranted();

      if (res == true) {
        await OverlayHelper.showLyricOverlay();
      } else {
        showToast("请给予Icey Player悬浮窗权限");

        Future.delayed(const Duration(milliseconds: 500)).then((_) {
          OverlayHelper.requestPermission();
        });
      }
    } else {
      if (await OverlayHelper.isActive()) {
        await OverlayHelper.closeOverlay();
      }
    }
  }

  void setImmersive(bool value) {
    _immersive.value = value;

    _saveSetting(CacheKey.Settings.immersive, value);
  }

  void setConcert(bool value) {
    _concert.value = value;

    _saveSetting(CacheKey.Settings.concert, value);
  }

  void setAudioFocus(bool value) {
    _audioFocus.value = value;

    _saveSetting(CacheKey.Settings.audioFocus, value);
  }

  void setAutoUpdate(bool value) {
    _autoUpdate.value = value;

    _saveSetting(CacheKey.Settings.autoUpdate, value);
  }
}
