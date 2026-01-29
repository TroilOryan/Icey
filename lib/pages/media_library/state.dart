part of 'controller.dart';

class MediaLibraryState {
  final focused = signal(false);

  final Signal<AzListCursorInfoModel?> cursorInfo = signal(null);
}
