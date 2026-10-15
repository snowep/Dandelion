import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dandelion/app/app_shell.dart';
import 'package:dandelion/features/home/home_screen.dart';
import 'package:dandelion/features/library/library_screen.dart';
import 'package:dandelion/features/wishlist/wishlist_screen.dart';
import 'package:dandelion/features/discover/discover_screen.dart';
import 'package:dandelion/features/insights/insights_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        // Determine selected index from location
        int selectedIndex = 0;
        final location = state.uri.toString();
        if (location.startsWith('/library')) {
          selectedIndex = 1;
        } else if (location.startsWith('/wishlist'))
          selectedIndex = 2;
        else if (location.startsWith('/discover'))
          selectedIndex = 3;
        else if (location.startsWith('/insights'))
          selectedIndex = 4;

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
    ),
  ],
);
