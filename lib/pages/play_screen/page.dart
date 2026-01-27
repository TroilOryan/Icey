part of 'controller.dart';

final playScreenController = PlayScreenController();

class PlayScreenPage extends StatefulWidget {
  const PlayScreenPage({super.key});

  @override
  State<PlayScreenPage> createState() => _PlayScreenPageState();
}

class _PlayScreenPageState extends State<PlayScreenPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    playScreenController.updateVsync(this);

    playScreenController.rotationController ??= AnimationController(
      duration: const Duration(seconds: 10),
      reverseDuration: const Duration(milliseconds: 100),
      vsync: this,
    );

    mediaManager.rotationAnimation.value = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(playScreenController.rotationController!);

    playScreenController.onInit();
  }

  @override
  void dispose() {
    playScreenController.onDispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final concert = settingsManager.concert.watch(context);

    final lyricOpened = playScreenController.state.lyricOpened.watch(context),
        offset = playScreenController.state.offset.watch(context);

    if(concert){
      return Concert();
    }

    return PopScope(
      canPop: !lyricOpened,
      onPopInvokedWithResult: playScreenController.handlePopInvokedWithResult,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            PlayScreenBackground(),
            OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.landscape) {
                  return Landscape();
                }

                return Portrait(
                  offset: offset,
                  lyricOpened: lyricOpened,
                  onOpenLyric: playScreenController.handleOpenLyric,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
