
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import '../helpers/common.dart';
import '../constants/box_key.dart';
import '../entities/media.dart';
import '../entities/media_order.dart';

Future<void> initHive() async {
  final dir = await CommonHelper().getAppDataDir();

  await Hive.initFlutter(path.join(dir.path, 'hive'));

  Hive.registerAdapter(MediaEntityAdapter(), override: true);
  Hive.registerAdapter(MediaOrderEntityAdapter(), override: true);

  await Hive.openBox(BoxKey.media);

  await Hive.openBox(BoxKey.settings);

  await Hive.openBox(BoxKey.liked);

  await Hive.openBox(BoxKey.mediaCount);

  await Hive.openBox(BoxKey.mediaOrder);
}
