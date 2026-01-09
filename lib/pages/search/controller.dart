part of 'page.dart';

class SearchController {
  final state = SearchState();

  FocusNode focusNode = FocusNode();

  void handleChanged(String? value) {
    if (value == null) {
      return;
    }

    final localMediaList = mediaManager.localMediaList.value;

    if (value.isEmpty) {
      state.mediaList.value = List.empty();

      return;
    }

    final valueUpper = value.toUpperCase(), valueLower = value.toLowerCase();

    state.mediaList.value = List.unmodifiable(
      localMediaList.where((media) {
        final artist = PinyinHelper.getPinyinE(media.artist!);
        final title = PinyinHelper.getPinyinE(media.title);

        return artist.contains(valueUpper) ||
            title.contains(valueUpper) ||
            artist.contains(valueLower) ||
            title.contains(valueLower) ||
            media.artist!.contains(valueUpper) ||
            media.title.contains(valueUpper) ||
            media.artist!.contains(valueLower) ||
            media.title.contains(valueLower);
      }).toList(),
    );
  }

  void handleMediaLongPress(MediaEntity media, BuildContext context) {
    focusNode.unfocus();

    Future.delayed(
      const Duration(milliseconds: 50),
    ).then((_) => homeController.handleMediaLongPress(media, context));
  }

  void onInit() {
    focusNode = FocusNode();

    Future.delayed(
      const Duration(milliseconds: 200),
    ).then((_) => focusNode.requestFocus());
  }

  void onDispose() {
    focusNode.unfocus();
    focusNode.dispose();
  }
}
