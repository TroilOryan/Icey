import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:signals/signals_flutter.dart';
import 'package:window_manager/window_manager.dart';

class TitleBarAction extends StatefulWidget {
  final bool? sideBarOpened;
  final bool? immersive;

  const TitleBarAction({super.key, this.sideBarOpened, this.immersive = false});

  @override
  State<TitleBarAction> createState() => _TitleBarActionState();
}

class _TitleBarActionState extends State<TitleBarAction> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    setState(() {});
  }

  @override
  void onWindowMinimize() {
    setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    setState(() {});
  }

  @override
  void onWindowRestore() {
    setState(() {});
  }

  @override
  void onWindowEnterFullScreen() {
    super.onWindowEnterFullScreen();
    setState(() {});
  }

  @override
  void onWindowLeaveFullScreen() {
    super.onWindowLeaveFullScreen();
    setState(() {});
  }

  void handleMinimize() {
    windowManager.minimize();
  }

  void handleMaximize(bool isMaximized) {
    if (isMaximized) {
      windowManager.unmaximize();

      return;
    }

    windowManager.maximize();
  }

  void handleClose() async {
    windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final appThemeExtension = AppThemeExtension.of(context);

    final mediaList = mediaManager.mediaList.watch(context);

    final iconColor = computed(
      () => widget.immersive == true
          ? appThemeExtension.secondary
          : theme.iconTheme.color,
    );

    return Positioned(
      right: 16,
      top: 0,
      height: 60,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Flexible(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                DragToMoveArea(
                  child: SizedBox(width: double.infinity, height: 60),
                ),
                Offstage(
                  offstage: widget.sideBarOpened == null,
                  child: LayoutBuilder(
                    builder: (context, constraints) => Container(
                      width: constraints.maxWidth * 0.4,
                      height: 40,
                      margin: EdgeInsets.only(
                        left: widget.sideBarOpened == true ? 340 : 100,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            SFIcons.sf_magnifyingglass,
                            size: 16,
                          ),
                          hint: Text(
                            "在${mediaList.length}个媒体中搜索",
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.normal,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: "最小化",
            onPressed: handleMinimize,
            icon: Icon(Symbols.remove, color: iconColor()),
          ),
          FutureBuilder(
            future: windowManager.isMaximized(),
            builder: (context, snapshot) {
              final isMaximized = snapshot.data ?? true;
              return IconButton(
                tooltip: isMaximized ? "还原" : "最大化",
                onPressed: () => handleMaximize(isMaximized),
                icon: Icon(
                  isMaximized
                      ? FluentIcons.window_multiple_16_filled
                      : FluentIcons.maximize_16_filled,
                  color: iconColor(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: "退出",
            color: Colors.red,
            onPressed: handleClose,
            icon: Icon(Icons.close, color: iconColor()),
          ),
        ],
      ),
    );
  }
}
