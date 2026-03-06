import 'package:IceyPlayer/models/lyric/lyric.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

final lyric = signal("");

class DesktopLyric extends StatelessWidget {
  const DesktopLyric({super.key});

  @override
  Widget build(BuildContext context) {
    final _lyric = lyric.watch(context);

    return MaterialApp(home: Material(child: Text(_lyric)));
  }
}
