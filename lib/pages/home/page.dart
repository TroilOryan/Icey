part of 'controller.dart';

final homeController = HomeController();

class HomePage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const HomePage({super.key, required this.navigationShell});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    homeController.onInit(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    homeController.onDispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final deviceWidth = MediaQuery.of(context).size.width;

    final deviceHeight = MediaQuery.of(context).size.height;

    final mediaList = mediaManager.mediaList.watch(context);

    final listBg = settingsManager.listBg.watch(context),
        listType = settingsManager.listType.watch(context);

    final isMediaList = computed(() => listType == ListType.media);

    final panelOpened = homeController.state.panelOpened.watch(context),
        hidePlayBar = homeController.state.hidePlayBar.watch(context);

    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return PopScope(
      canPop: !panelOpened,
      onPopInvokedWithResult: homeController.handlePopInvokedWithResult,
      child: LiquidGlassScope.stack(
        background: listBg.isNotEmpty
            ? Stack(
                children: [
                  Image.memory(
                    listBg,
                    fit: BoxFit.cover,
                    width: deviceWidth,
                    height: deviceHeight,
                  ),
                  Offstage(
                    offstage: !isDarkMode,
                    child: Container(
                      color: Colors.black45,
                      width: deviceWidth,
                      height: deviceHeight,
                    ),
                  ),
                ],
              )
            : Container(),
        content: Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: listBg.isNotEmpty
              ? Colors.transparent
              : theme.scaffoldBackgroundColor,
          bottomNavigationBar: BottomBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onSearch: () => homeController.navToSearch(context),
            onTabSelected: widget.navigationShell.goBranch,
          ),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              widget.navigationShell,
              PlayBar(
                hidePlayBar: hidePlayBar,
                onTap: () => homeController.handleOpenPanel(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
