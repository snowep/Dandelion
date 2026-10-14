import 'package:flutter/material.dart';
import 'package:dandelion/features/home/home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Home',
    'Library',
    'Wishlist',
    'Discover',
    'Insights',
  ];

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const Center(child: Text('Library Content'));
      case 2:
        return const Center(child: Text('Wishlist Content'));
      case 3:
        return const Center(child: Text('Discover Content'));
      case 4:
        return const Center(child: Text('Insights Content'));
      default:
        return const Center(child: Text('Unknown'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 720;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isCompact) {
            return Column(
              children: [
                const SliverAppBarWidget(title: 'Dandelion Home'),
                Expanded(child: _buildBody()),
                NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (i) =>
                      setState(() => _selectedIndex = i),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.library_books_outlined),
                      selectedIcon: Icon(Icons.library_books),
                      label: 'Library',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.favorite_border),
                      selectedIcon: Icon(Icons.favorite),
                      label: 'Wishlist',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore),
                      label: 'Discover',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.insights_outlined),
                      selectedIcon: Icon(Icons.insights),
                      label: 'Insights',
                    ),
                  ],
                ),
              ],
            );
          } else {
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (i) =>
                      setState(() => _selectedIndex = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.library_books_outlined),
                      selectedIcon: Icon(Icons.library_books),
                      label: Text('Library'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite_border),
                      selectedIcon: Icon(Icons.favorite),
                      label: Text('Wishlist'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore),
                      label: Text('Discover'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.insights_outlined),
                      selectedIcon: Icon(Icons.insights),
                      label: Text('Insights'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: _buildBody()),
              ],
            );
          }
        },
      ),
    );
  }
}
