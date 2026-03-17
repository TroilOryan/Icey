part of 'controller.dart';

class PlayLyricOverlayState {
  final lyric = signal("");

  final duration = signal(1500);

  final color = signal(Settings.textColor.first.color);

  final fontSize = signal(16.0);

  final width = signal(50.0);

  final playing = signal(false);

  final visible = signal(true);
}
