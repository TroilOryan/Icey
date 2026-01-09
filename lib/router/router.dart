import 'package:IceyPlayer/pages/album_list_detail/page.dart';
import 'package:IceyPlayer/pages/artist_list_detail/page.dart';
import 'package:IceyPlayer/pages/home/controller.dart';
import 'package:IceyPlayer/pages/media_order_detail/page.dart';
import 'package:IceyPlayer/pages/player_style/page.dart';
import 'package:IceyPlayer/pages/search/page.dart';
import 'package:IceyPlayer/pages/settings/about/page.dart';
import 'package:IceyPlayer/pages/settings/audio_output/page.dart';
import 'package:IceyPlayer/pages/settings/interface/high_material/high_material.dart';
import 'package:IceyPlayer/pages/settings/interface/page.dart';
import 'package:IceyPlayer/pages/settings/lyric/page.dart';
import 'package:IceyPlayer/pages/settings/media_store/page.dart';
import 'package:IceyPlayer/pages/settings/page.dart';
import 'package:IceyPlayer/pages/settings/pro/page.dart';
import 'package:IceyPlayer/pages/settings/pro/pay/page.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: "/",
  routes: <RouteBase>[
    // StatefulShellRoute.indexedStack(
    //   restorationScopeId: 'appShell',
    //   pageBuilder:
    //       (
    //         BuildContext context,
    //         GoRouterState state,
    //         StatefulNavigationShell navigationShell,
    //       ) {
    //         return MaterialPage<void>(
    //           restorationId: 'appShellPage',
    //           child: HomePage(navigationShell: navigationShell),
    //         );
    //       },
    //   branches: <StatefulShellBranch>[
    //     StatefulShellBranch(
    //       routes: <GoRoute>[
    //         GoRoute(path: '/', builder: (_, __) => const MediaLibraryPage()),
    //       ],
    //     ),
    //     StatefulShellBranch(
    //       routes: <GoRoute>[
    //         GoRoute(
    //           path: '/album_list',
    //           builder: (_, __) => const AlbumListPage(),
    //         ),
    //       ],
    //     ),
    //     StatefulShellBranch(
    //       routes: <GoRoute>[
    //         GoRoute(
    //           path: '/artist_list',
    //           builder: (_, __) => const ArtistListPage(),
    //         ),
    //       ],
    //     ),
    //   ],
    // ),
    GoRoute(path: '/', builder: (_, state) => const HomePage()),
    GoRoute(
      path: '/album_list_detail/:id',
      builder: (_, state) => const AlbumListDetailPage(),
    ),
    GoRoute(
      path: '/artist_list_detail/:id',
      builder: (_, state) => const ArtistListDetailPage(),
    ),
    GoRoute(
      path: '/media_order_detail/:id',
      builder: (_, state) => const MediaOrderDetailPage(),
    ),
    GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
    GoRoute(path: '/player_style', builder: (_, __) => const PlayerStylePage()),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsPage(),
      routes: [
        GoRoute(
          path: '/pro',
          builder: (_, __) => const ProPage(),
          routes: [GoRoute(path: '/pay', builder: (_, __) => const PayPage())],
        ),
        GoRoute(
          path: '/media_store',
          builder: (_, __) => const MediaStorePage(),
        ),
        GoRoute(
          path: '/interface',
          builder: (_, __) => const InterfacePage(),
          routes: [
            GoRoute(
              path: '/high_material',
              builder: (_, __) => const HighMaterialPage(),
            ),
          ],
        ),
        GoRoute(path: '/lyric', builder: (_, __) => const LyricPage()),
        GoRoute(
          path: '/audio_output',
          builder: (_, __) => const AudioOutputPage(),
        ),
        GoRoute(path: '/about', builder: (_, __) => const AboutPage()),
      ],
    ),
  ],
);
