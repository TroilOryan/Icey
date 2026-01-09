import 'package:signals/signals_flutter.dart';

import 'az_list_cursor/az_list_cursor.dart';

class MediaLibraryState {
  final focused = signal(false);

  final Signal<AzListCursorInfoModel?> cursorInfo = signal(null);
}
