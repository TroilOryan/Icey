import 'dart:typed_data';

import 'package:IceyPlayer/entities/media.dart';
import 'package:signals/signals_flutter.dart';

class MediaOrderDetailState {
  final Signal<List<MediaEntity>> mediaList = signal([]);

  /// 当修改了封面时，不能立即生效
  /// 用暂定的更新界面
  final Signal<Uint8List?> tempCover = signal(null);
}
