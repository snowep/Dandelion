import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/insights_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/library',
      builder: (context, state) => const LibraryScreen(),
    ),
    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const WishlistScreen(),
    ),
    GoRoute(
      path: '/discover',
      builder: (context, state) => const DiscoverScreen(),
    ),
    GoRoute(
      path: '/insights',
      builder: (context, state) => const InsightsScreen(),
    ),
  ],
);
