import 'package:go_router/go_router.dart';
import 'package:dandelion/app/app_shell.dart';
import 'package:dandelion/features/home/home_screen.dart';
import 'package:dandelion/features/library/book_database.dart';
import 'package:dandelion/features/library/book_repository.dart';
import 'package:dandelion/features/library/book_repository_impl.dart';
import 'package:dandelion/features/library/library_screen.dart';
import 'package:dandelion/features/wishlist/wishlist_screen.dart';
import 'package:dandelion/features/discover/discover_screen.dart';
import 'package:dandelion/features/insights/insights_screen.dart';

final BookRepository _bookRepository = BookRepositoryImpl(AppDatabase());

final GoRouter appRouter = createAppRouter(_bookRepository);

GoRouter createAppRouter(BookRepository repository) => GoRouter(
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
          builder: (context, state) => LibraryScreen(repository: repository),
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
    ),
  ],
);
