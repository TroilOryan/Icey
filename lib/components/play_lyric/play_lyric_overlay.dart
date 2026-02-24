import 'package:IceyPlayer/constants/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:signals/signals_flutter.dart';

class PlayLyricOverlay extends StatefulWidget {
  const PlayLyricOverlay({super.key});

  @override
  State<PlayLyricOverlay> createState() => _PlayLyricOverlayState();
}

class _PlayLyricOverlayState extends State<PlayLyricOverlay> {
  final lyric = signal("");

  final color = signal(Settings.textColor.first.color);

  final fontSize = signal(16.0);

  final width = signal(50.0);

  void onInit() {
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event?["lyric"] != null) {
        lyric.value = event["lyric"];
      }

      if (event?["fontSize"] != null) {
        fontSize.value = event["fontSize"].toDouble();
      }

      if (event?["width"] != null) {
        width.value = event["width"].toDouble();
      }

      if (event?["color"] != null) {
        color.value = Color(event["color"]);
      }
    });
  }

  void onDispose() {
    FlutterOverlayWindow.disposeOverlayListener();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    onInit();
  }

  @override
  void dispose() {
    onDispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _lyric = lyric.watch(context),
        _color = color.watch(context),
        _fontSize = fontSize.watch(context),
        _width = width.watch(context);

    final textStyle = computed(
      () => TextStyle(
        color: _color,
        fontSize: _fontSize,
        fontWeight: FontWeight.bold,
      ),
    );

    return Material(
      type: MaterialType.transparency,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _width),
        child: Stack(
          children: [
            SizedBox(
              width: _width,
              child: Text(
                _lyric.isEmpty ? "暂无歌词" : _lyric,
                style: textStyle(),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
