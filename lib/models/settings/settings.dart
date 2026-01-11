import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/constants/cache_key.dart';
import 'package:IceyPlayer/helpers/media/media.dart';
import 'package:IceyPlayer/helpers/media_scanner/media_sort.dart';
import 'package:flutter/material.dart';
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

enum ListType {
  media(value: "media", name: "媒体列表"),
  album(value: "album", name: "专辑列表"),
  artist(value: "artist", name: "艺术家列表");

  final String value;
  final String name;

  const ListType({required this.value, required this.name});

  static ListType getByValue(String value) {
    return values.firstWhere((element) => element.value == value);
  }

  static ListType getByName(String value) {
    return values.firstWhere((element) => element.name == value);
  }
}

class SettingsManager {
  final Signal<MediaSort> _sortType;
  final Signal<BrightnessTheme> _brightnessTheme;
  final Signal<ListType> _listType;
  final Signal<bool> _isMaterialScrollBehavior;
  final Signal<CoverShape> _coverShape;
  final Signal<bool> _artCover;
  final Signal<bool> _wakelock;
  final Signal<bool> _dynamicLight;
  final Signal<Uint8List> _listBg;
  final Signal<bool> _highMaterial;
  final Signal<bool> _karaoke;
  final Signal<bool> _fakeEnhanced;
  final Signal<bool> _immersive;
  final Signal<bool> _audioFocus;
  final Signal<bool> _autoUpdate;

  Signal<MediaSort> get sortType => _sortType;

  Signal<BrightnessTheme> get brightnessTheme => _brightnessTheme;

  Signal<ListType> get listType => _listType;

  Signal<bool> get isMaterialScrollBehavior => _isMaterialScrollBehavior;

  Signal<CoverShape> get coverShape => _coverShape;

  Signal<bool> get artCover => _artCover;

  Signal<bool> get wakelock => _wakelock;

  Signal<bool> get dynamicLight => _dynamicLight;

  Signal<Uint8List> get listBg => _listBg;

  Signal<bool> get highMaterial => _highMaterial;

  Signal<bool> get karaoke => _karaoke;

  Signal<bool> get fakeEnhanced => _fakeEnhanced;

  Signal<bool> get immersive => _immersive;

  Signal<bool> get audioFocus => _audioFocus;

  Signal<bool> get autoUpdate => _autoUpdate;

  SettingsManager()
    : _sortType = signal(MediaSort.title),
      _brightnessTheme = signal(BrightnessTheme.system),
      _listType = signal(ListType.media),
      _isMaterialScrollBehavior = signal(false),
      _coverShape = signal(CoverShape.circle),
      _artCover = signal(true),
      _wakelock = signal(false),
      _dynamicLight = signal(true),
      _listBg = signal(Uint8List(0)),
      _highMaterial = signal(true),
      _karaoke = signal(true),
      _fakeEnhanced = signal(false),
      _immersive = signal(false),
      _audioFocus = signal(true),
      _autoUpdate = signal(true) {
    _sortType.value = MediaSort.getByValue(
      _settingsBox.get(
        CacheKey.Settings.sortType,
        defaultValue: MediaSort.title.value,
      ),
    );

    _brightnessTheme.value = BrightnessTheme.getByValue(
      _settingsBox.get(
        CacheKey.Settings.brightnessTheme,
        defaultValue: BrightnessTheme.system.value,
      ),
    );

    _listType.value = ListType.getByValue(
      _settingsBox.get(
        CacheKey.Settings.listType,
        defaultValue: ListType.media.value,
      ),
    );

    _isMaterialScrollBehavior.value = _settingsBox.get(
      CacheKey.Settings.isMaterialScrollBehavior,
      defaultValue: false,
    );

    _coverShape.value = CoverShape.getByValue(
      _settingsBox.get(
        CacheKey.Settings.coverShape,
        defaultValue: CoverShape.circle.value,
      ),
    );

    _artCover.value = _settingsBox.get(
      CacheKey.Settings.artCover,
      defaultValue: true,
    );

    _wakelock.value = _settingsBox.get(
      CacheKey.Settings.wakelock,
      defaultValue: true,
    );

    _dynamicLight.value = _settingsBox.get(
      CacheKey.Settings.dynamicLight,
      defaultValue: false,
    );

    _listBg.value = _settingsBox.get(
      CacheKey.Settings.listBg,
      defaultValue: Uint8List(0),
    );

    _highMaterial.value = _settingsBox.get(
      CacheKey.Settings.highMaterial,
      defaultValue: true,
    );

    _fakeEnhanced.value = _settingsBox.get(
      CacheKey.Settings.fakeEnhanced,
      defaultValue: false,
    );

    _immersive.value = _settingsBox.get(
      CacheKey.Settings.immersive,
      defaultValue: false,
    );

    _audioFocus.value = _settingsBox.get(
      CacheKey.Settings.audioFocus,
      defaultValue: true,
    );

    _autoUpdate.value = _settingsBox.get(
      CacheKey.Settings.autoUpdate,
      defaultValue: true,
    );
  }

  void setSortType(MediaSort value) {
    _sortType.value = value;

    _settingsBox.put(CacheKey.Settings.sortType, value.value);

    MediaHelper.queryLocalMedia();
  }

  void setBrightnessTheme(BrightnessTheme value) {
    _brightnessTheme.value = value;

    _settingsBox.put(CacheKey.Settings.brightnessTheme, value.value);
  }

  void setListType(ListType value) {
    _listType.value = value;

    _settingsBox.put(CacheKey.Settings.listType, value.value);
  }

  void setIsMaterialScrollBehavior(bool value) {
    _isMaterialScrollBehavior.value = value;

    _settingsBox.put(CacheKey.Settings.isMaterialScrollBehavior, value);
  }

  void setCoverShape(CoverShape value) {
    _coverShape.value = value;

    _settingsBox.put(CacheKey.Settings.coverShape, value.value);
  }

  void setArtCover(bool value) {
    _artCover.value = value;

    _settingsBox.put(CacheKey.Settings.artCover, value);
  }

  void setWakelock(bool value) {
    _wakelock.value = value;

    _settingsBox.put(CacheKey.Settings.wakelock, value);
  }

  void setDynamicLight(bool value) {
    _dynamicLight.value = value;

    _settingsBox.put(CacheKey.Settings.dynamicLight, value);
  }

  void setListBg(Uint8List value) {
    _listBg.value = value;

    _settingsBox.put(CacheKey.Settings.listBg, value);
  }

  void setHighMaterial(bool value) {
    _highMaterial.value = value;

    _settingsBox.put(CacheKey.Settings.highMaterial, value);
  }

  void setKaraoke(bool value) {
    _karaoke.value = value;

    _settingsBox.put(CacheKey.Settings.karaoke, value);
  }

  void setFakeEnhanced(bool value) {
    _fakeEnhanced.value = value;

    _settingsBox.put(CacheKey.Settings.fakeEnhanced, value);
  }

  void setImmersive(bool value) {
    _immersive.value = value;

    _settingsBox.put(CacheKey.Settings.immersive, value);
  }

  void setAudioFocus(bool value) {
    _audioFocus.value = value;

    _settingsBox.put(CacheKey.Settings.audioFocus, value);
  }

  void setAutoUpdate(bool value) {
    _autoUpdate.value = value;

    _settingsBox.put(CacheKey.Settings.autoUpdate, value);
  }
}
