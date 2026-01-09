import 'package:hive_ce/hive.dart';

class BoxKey {
  static String media = 'media';

  static String mediaCount = "mediaCount";

  static String artworkColor = "artworkColor";

  /// 歌单
  static String mediaOrder = 'mediaOrder';

  /// 我喜欢
  static String liked = "liked";

  /// 设置
  static String settings = 'settings';
}

class Boxes {
  static final mediaBox = Hive.box(BoxKey.media);

  static final mediaCountBox = Hive.box(BoxKey.mediaCount);

  static final artworkColorBox = Hive.box(BoxKey.artworkColor);

  static final mediaOrderBox = Hive.box(BoxKey.mediaOrder);

  static final likedBox = Hive.box(BoxKey.liked);

  static final settingsBox = Hive.box(BoxKey.settings);
}
