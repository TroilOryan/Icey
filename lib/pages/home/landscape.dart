import 'package:flutter/material.dart';
import 'package:IceyPlayer/pages/album_list/controller.dart';
import 'package:IceyPlayer/pages/artist_list/controller.dart';
import 'package:IceyPlayer/pages/home/header_tab_bar/header_tab_bar.dart';
import 'package:IceyPlayer/pages/media_library/controller.dart';

class Landscape extends StatelessWidget {
  const Landscape({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(flex: 1, child: HeaderTabBar(offstage: false, onTap: (s) {})),
        Flexible(
          flex: 3,
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [MediaLibraryPage(), AlbumListPage(), ArtistListPage()],
          ),
        ),
      ],
    );
  }
}
