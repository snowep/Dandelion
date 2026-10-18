import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dandelion/app/app_shell.dart';
import 'package:dandelion/features/home/home_screen.dart';
import 'package:dandelion/features/library/library_notifier.dart';
import 'package:dandelion/features/library/library_screen.dart';
import 'package:dandelion/features/wishlist/wishlist_screen.dart';
import 'package:dandelion/features/discover/discover_screen.dart';
import 'package:dandelion/features/insights/insights_screen.dart';

final GoRouter appRouter = createAppRouter();

GoRouter createAppRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final selectedIndex = switch (state.matchedLocation) {
          '/library' => 1,
          '/wishlist' => 2,
          '/discover' => 3,
          '/insights' => 4,
          _ => 0,
        };

        return AppShell(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/library');
                break;
              case 2:
                context.go('/wishlist');
                break;
              case 3:
                context.go('/discover');
                break;
              case 4:
                context.go('/insights');
                break;
            }
          },
          child: child,
        );
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/library',
          builder: (context, state) => Consumer(
            builder: (context, ref, _) => LibraryScreen(
              repository: ref.read(bookRepositoryProvider),
            ),
          ),
        ),
        GoRoute(
          path: '/wishlist',
          builder: (context, state) => Consumer(
            builder: (context, ref, _) => WishlistScreen(
              repository: ref.read(bookRepositoryProvider),
            ),
          ),
        ),
        GoRoute(
          path: '/discover',
          builder: (context, state) => Consumer(
            builder: (context, ref, _) => DiscoverScreen(
              repository: ref.read(bookRepositoryProvider),
            ),
          ),
        ),
        GoRoute(
          path: '/insights',
          builder: (context, state) => const InsightsScreen(),
        ),
      ],
    ),
  ],
);
