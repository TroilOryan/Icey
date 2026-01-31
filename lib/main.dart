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
import 'entities/media.dart';
import 'entities/media_order.dart';
import 'helpers/media/media.dart';
import 'http/init.dart';

part 'main.g.dart';

part 'state.dart';

final appState = AppState();

Future<void> main() async {
  await initServices();

  // 异常捕获 logo记录
  final customParameters = {
    'BuildConfig':
        '\nBuild Time: ${DateUtil.formatDateMs(BuildConfig.buildTime, isUtc: true, format: DateFormats.full)}\n'
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

  Catcher2(
    debugConfig: debugConfig,
    releaseConfig: releaseConfig,
    rootWidget: const App(),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  Future onInit() async {
    WidgetsBinding.instance.addObserver(this);

    GoTransition.defaultCurve = Curves.easeInOutSine;
    GoTransition.defaultDuration = const Duration(milliseconds: 600);

    setDisplayMode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _brightnessThemeListener = effect(() {
        if (settingsManager.brightnessTheme.value == BrightnessTheme.system) {
          appState.brightness.value = MediaQuery.of(context).platformBrightness;
        } else if (settingsManager.brightnessTheme.value ==
            BrightnessTheme.light) {
          appState.brightness.value = Brightness.light;
        } else {
          appState.brightness.value = Brightness.dark;
        }
      });
    });
  }

  Future onDispose() async {
    _brightnessThemeListener();

    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();

    _didChangePlatformBrightness();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    onDispose();
  }

  @override
  Widget build(BuildContext context) {
    precacheAssets(context);

    final coverColor = mediaManager.coverColor.watch(context),
        brightness = appState.brightness.watch(context),
        statusBarIconBrightness = appState.statusBarIconBrightness.watch(
          context,
        ),
        artCover = settingsManager.artCover.watch(context),
        themeMode = settingsManager.brightnessTheme.watch(context),
        isMaterialScrollBehavior = settingsManager.isMaterialScrollBehavior
            .watch(context),
        immersive = settingsManager.immersive.watch(context);

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
      child: OrientationBuilder(
        builder: (context, orientation) {
          SystemChrome.setEnabledSystemUIMode(
            orientation == Orientation.landscape || immersive
                ? SystemUiMode.immersive
                : SystemUiMode.edgeToEdge,
          );

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            restorationScopeId: 'mainApp',
            themeMode: BrightnessTheme.toThemeMode(themeMode.value),
            scrollBehavior: scrollBehavior.value,
            routerConfig: router,
            title: 'Icey Player',
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
          );
        },
      ),
    );
  }
}
