import 'package:flutter/material.dart';
import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/page_wrapper/page_wrapper.dart';

class PlayerStylePage extends StatelessWidget {
  const PlayerStylePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: "播放器样式",
      body: ListCard(children: []),
    );
  }
}
