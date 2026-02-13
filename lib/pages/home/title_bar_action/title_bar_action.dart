import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:signals/signals_flutter.dart';
import 'package:window_manager/window_manager.dart';

class TitleBarAction extends StatefulWidget {
  const TitleBarAction({super.key});

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
    return Positioned(
      right: 16,
      top: 0,
      height: 60,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Flexible(
            child: DragToMoveArea(
              child: SizedBox(width: double.infinity, height: 60),
            ),
          ),
          IconButton(
            tooltip: "最小化",
            onPressed: handleMinimize,
            icon: const Icon(Symbols.remove),
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
                ),
              );
            },
          ),
          IconButton(
            tooltip: "退出",
            color: Colors.red,
            onPressed: handleClose,
            icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
          ),
        ],
      ),
    );
  }
}
