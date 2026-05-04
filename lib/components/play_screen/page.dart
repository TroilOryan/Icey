part of 'controller.dart';

final playScreenController = PlayScreenController();

class PlayScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const PlayScreen({super.key, this.onClose});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  @override
  void initState() {
    super.initState();

    // 监听 pageController 更新 currentPage 信号
    playScreenController.pageController.addListener(_onPageControllerChanged);
  }

  void _onPageControllerChanged() {
    final page = playScreenController.pageController.page?.round();
    if (page != null && page != playScreenController.state.currentPage.value) {
      playScreenController.state.currentPage.value = page;
    }
  }

  @override
  void dispose() {
    playScreenController.pageController
        .removeListener(_onPageControllerChanged);
    playScreenController.onDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage =
        playScreenController.state.currentPage.watch(context);

    final concert = settingsManager.concert.watch(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // 非初始页，回到初始页
        if (currentPage != 1) {
          playScreenController.pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          return;
        }

        widget.onClose?.call();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: concert
            ? Concert(onClose: widget.onClose)
            : Stack(
                children: [
                  const PlayScreenBackground(),
                  AdaptiveBuilder(
                    mobile: (context) => Portrait(
                      pageController: playScreenController.pageController,
                      onOpenLyric: playScreenController.handleOpenLyric,
                      onOpenPlaylist: playScreenController.handleOpenPlaylist,
                      onClose: widget.onClose,
                    ),
                    landscape: (context) => OrientationBuilder(
                      builder: (context, orientation) {
                        if (orientation == Orientation.landscape) {
                          return const Landscape();
                        }

                        return Portrait(
                          pageController: playScreenController.pageController,
                          onOpenLyric: playScreenController.handleOpenLyric,
                          onOpenPlaylist:
                              playScreenController.handleOpenPlaylist,
                          onClose: widget.onClose,
                        );
                      },
                    ),
                    tablet: (context) => Tablet(onClose: widget.onClose),
                  ),
                ],
              ),
      ),
    );
  }
}
