
import 'package:catcher_2/catcher_2.dart';
import '../helpers/logs/json_file_handler.dart';
import '../build_config.dart';
import 'package:common_utils/common_utils.dart';

Future<Map<String, Catcher2Options>> initCatcher() async {
  // 异常捕获 logo记录
  final customParameters = {
    'BuildConfig':
        '\nBuild Time: ${DateUtil.formatDateMs(BuildConfig.buildTime * 1000, isUtc: true, format: DateFormats.full)}\n'
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
