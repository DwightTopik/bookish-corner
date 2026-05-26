import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookish_corner/app/scaffold_with_nav.dart';
import 'package:bookish_corner/features/auth/presentation/screens/auth_screen.dart';
import 'package:bookish_corner/features/library/presentation/screens/add_book_screen.dart';
import 'package:bookish_corner/features/library/presentation/screens/library_screen.dart';
import 'package:bookish_corner/features/library/presentation/screens/search_screen.dart';
import 'package:bookish_corner/features/player/presentation/screens/player_screen.dart';
import 'package:bookish_corner/features/reader/presentation/screens/reader_screen.dart';
import 'package:bookish_corner/features/settings/presentation/screens/settings_screen.dart';
import 'package:bookish_corner/features/tracker/presentation/screens/tracker_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/library',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNav(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tracker',
                builder: (context, state) => const TrackerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/library/add',
        builder: (context, state) => const AddBookScreen(),
      ),
      GoRoute(
        path: '/reader/:bookId',
        builder: (context, state) => ReaderScreen(
          bookId: state.pathParameters['bookId']!,
        ),
      ),
      GoRoute(
        path: '/player/:bookId',
        builder: (context, state) => PlayerScreen(
          bookId: state.pathParameters['bookId']!,
        ),
      ),
    ],
  );
});
