import 'dart:io';
import 'dart:ui';

import 'package:IceyPlayer/helpers/logs/json_file_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:catcher_2/catcher_2.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/pages/home/controller.dart';
import 'package:IceyPlayer/router/router.dart';
import 'package:IceyPlayer/services/audio_service.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_transitions/go_transitions.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:signals/signals_flutter.dart';
import 'build_config.dart';
import 'constants/box_key.dart';
import 'constants/cache_key.dart';
import 'constants/strings.dart';
import 'entities/media.dart';
import 'entities/media_order.dart';
import 'helpers/media/media.dart';
import 'http/init.dart';

part 'state.dart';

part 'controller.dart';

final appController = AppController();

Future<void> main() async {
  final res = await appController.initServices();

  Catcher2(
    debugConfig: res["debugConfig"],
    releaseConfig: res["releaseConfig"],
    rootWidget: const App(),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();

    appController.didChangePlatformBrightness();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    appController.onInit(context);

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    appController.onDispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coverColor = mediaManager.coverColor.watch(context),
        brightness = appController.state.brightness.watch(context),
        statusBarIconBrightness = appController.state.statusBarIconBrightness
            .watch(context),
        artCover = settingsManager.artCover.watch(context),
        themeMode = settingsManager.brightnessTheme.watch(context),
        isMaterialScrollBehavior = settingsManager.isMaterialScrollBehavior
            .watch(context);

    final scrollBehavior = computed(
      () => isMaterialScrollBehavior
          ? const MaterialScrollBehavior()
          : const CupertinoScrollBehavior(),
    );

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: statusBarIconBrightness,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: MaterialApp.router(
        restorationScopeId: 'mainApp',
        themeMode: BrightnessTheme.toThemeMode(themeMode.value),
        scrollBehavior: scrollBehavior.value,
        routerConfig: router,
        title: Strings.appName,
        theme: AppTheme.theme(
          isLightCover: !coverColor.isDark,
          artCover: artCover,
          colorScheme: SeedColorScheme.fromSeeds(
            primaryKey: Color(coverColor.primary),
            brightness: brightness,
            tones: FlexTones.highContrast(brightness),
          ),
        ).useSystemChineseFont(brightness),
        darkTheme: AppTheme.theme(
          isLightCover: !coverColor.isDark,
          artCover: artCover,
          colorScheme: SeedColorScheme.fromSeeds(
            primaryKey: Color(coverColor.primary),
            brightness: brightness,
            tones: FlexTones.highContrast(brightness),
          ),
        ).useSystemChineseFont(brightness),
      ),
    );
  }
}
