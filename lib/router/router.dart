import 'package:IceyPlayer/pages/album_list/controller.dart';
import 'package:IceyPlayer/pages/artist_list/controller.dart';
import 'package:IceyPlayer/pages/home/controller.dart';
import 'package:IceyPlayer/pages/media_library/controller.dart';
import 'package:IceyPlayer/pages/settings/about/logs/logs_detail/page.dart';
import 'package:IceyPlayer/pages/settings/about/logs/page.dart';
import 'package:IceyPlayer/pages/settings/about/page.dart';
import 'package:IceyPlayer/pages/settings/audio_output/page.dart';
import 'package:IceyPlayer/pages/settings/interface/high_material/high_material.dart';
import 'package:IceyPlayer/pages/settings/interface/page.dart';
import 'package:IceyPlayer/pages/settings/lyric/page.dart';
import 'package:IceyPlayer/pages/settings/media_store/page.dart';
import 'package:IceyPlayer/pages/settings/page.dart';
import 'package:IceyPlayer/pages/settings/pro/page.dart';
import 'package:IceyPlayer/pages/settings/pro/pay/page.dart';
import 'package:IceyPlayer/pages/sub_pages/artist_list_detail/controller.dart';
import 'package:IceyPlayer/pages/sub_pages/media_order_detail/controller.dart';
import 'package:IceyPlayer/pages/sub_pages/play_screen/controller.dart';
import 'package:IceyPlayer/pages/sub_pages/player_style/page.dart';
import 'package:IceyPlayer/pages/sub_pages/search/controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_transitions/go_transitions.dart';

import '../pages/sub_pages/album_list_detail/controller.dart';

final GoRouter router = GoRouter(
  initialLocation: "/",
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      restorationScopeId: 'appShell',
      pageBuilder:
          (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return MaterialPage<void>(
              restorationId: 'appShellPage',
              child: HomePage(navigationShell: navigationShell),
            );
          },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <GoRoute>[
            GoRoute(path: '/', builder: (_, _) => const MediaLibraryPage()),
          ],
        ),
        StatefulShellBranch(
          routes: <GoRoute>[
            GoRoute(
              path: '/album_list',
              builder: (_, _) => const AlbumListPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <GoRoute>[
            GoRoute(
              path: '/artist_list',
              builder: (_, _) => const ArtistListPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <GoRoute>[
            GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
          ],
        ),
      ],
    ),
    // GoRoute(path: '/', builder: (_, state) => const HomePage()),
    GoRoute(
      path: '/play_screen',
      pageBuilder: GoTransitions.slide.toTop.build(
        builder: (_, _) => const PlayScreenPage(),
      ),
    ),
    GoRoute(
      path: '/album_list_detail/:id',
      builder: (_, _) => const AlbumListDetailPage(),
    ),
    GoRoute(
      path: '/artist_list_detail/:id',
      builder: (_, _) => const ArtistListDetailPage(),
    ),
    GoRoute(
      path: '/media_order_detail/:id',
      builder: (_, _) => const MediaOrderDetailPage(),
    ),
    GoRoute(path: '/search', builder: (_, _) => const SearchPage()),
    GoRoute(path: '/player_style', builder: (_, _) => const PlayerStylePage()),
    GoRoute(
      path: '/settings',
      builder: (_, _) => const SettingsPage(),
      routes: [
        GoRoute(
          path: '/pro',
          builder: (_, _) => const ProPage(),
          routes: [GoRoute(path: '/pay', builder: (_, __) => const PayPage())],
        ),
        GoRoute(
          path: '/media_store',
          builder: (_, _) => const MediaStorePage(),
        ),
        GoRoute(
          path: '/interface',
          builder: (_, _) => const InterfacePage(),
          routes: [
            GoRoute(
              path: '/high_material',
              builder: (_, _) => const HighMaterialPage(),
            ),
          ],
        ),
        GoRoute(path: '/lyric', builder: (_, _) => const LyricPage()),
        GoRoute(
          path: '/audio_output',
          builder: (_, _) => const AudioOutputPage(),
        ),
        GoRoute(
          path: '/about',
          builder: (_, _) => const AboutPage(),
          routes: [
            GoRoute(
              path: '/logs',
              builder: (_, _) => const LogsPage(),
              routes: [
                GoRoute(
                  path: '/detail',
                  builder: (_, _) => const LogsDetailPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
