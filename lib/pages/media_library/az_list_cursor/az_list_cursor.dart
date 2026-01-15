import 'dart:ui';

import 'package:flutter/material.dart';

class AzListCursorInfoModel {
  final String title;
  final Offset offset;

  const AzListCursorInfoModel({required this.title, required this.offset});
}

class AzListCursor extends StatelessWidget {
  final double size;
  final String title;

  const AzListCursor({super.key, required this.size, required this.title});

  @override
  Widget build(BuildContext context) {
    Widget buildTitle() {
      Widget resultWidget = Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 32),
      );

      resultWidget = ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(100)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black54,
            ),
            child: resultWidget,
          ),
        ),
      );

      return resultWidget;
    }

    return buildTitle();
  }
}
