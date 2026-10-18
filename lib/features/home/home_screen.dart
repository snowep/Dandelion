import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dandelion/features/dashboard/dashboard_models.dart';
import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/insights/dashboard_providers.dart';
import 'package:dandelion/shared/services/cover_image_service.dart';
import 'package:dandelion/shared/widgets/primary_button.dart';
import 'package:dandelion/shared/widgets/sliver_app_bar_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DashboardMetrics> metricsAsync = ref.watch(
      dashboardMetricsProvider,
    );
    final AsyncValue<List<Book>> recentlyUpdatedAsync = ref.watch(
      recentlyUpdatedBooksProvider(5),
    );

    return CustomScrollView(
      slivers: [
        const SliverAppBarWidget(title: 'Dandelion Home'),
        metricsAsync.when(
          data: (metrics) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to Dandelion',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  const Text('Your personal library dashboard.'),
                  const SizedBox(height: 16),
                  _buildSummaryCards(context, metrics),
                  const SizedBox(height: 24),
                  _buildRecentlyUpdatedSection(context, recentlyUpdatedAsync),
                  if (metrics.totalBooks == 0) ...[
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Get Started',
                      onPressed: () {
                        context.go('/library');
                      },
                      semanticLabel: 'Get started button',
                    ),
                  ],
                ],
              ),
            ),
          ),
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Could not load your dashboard: $error',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref.refresh(dashboardMetricsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, DashboardMetrics metrics) {
    return Row(
      children: [
        Expanded(
          child: _buildCard(
            context,
            'Total Books',
            '${metrics.totalBooks}',
            Icons.menu_book,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCard(
            context,
            'Currently Reading',
            '${metrics.currentlyReading}',
            Icons.library_books,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCard(
            context,
            'Wishlist',
            '${metrics.wishlistCount}',
            Icons.favorite_border,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyUpdatedSection(
    BuildContext context,
    AsyncValue<List<Book>> recentlyUpdatedAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recently Updated',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        recentlyUpdatedAsync.when(
          data: (books) => books.isEmpty
              ? const Text(
                  'No books yet. Add your first book to get started!',
                  style: TextStyle(color: Colors.grey),
                )
              : SizedBox(
                  height: 108,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<Uint8List?>(
                              future:
                                  book.coverAssetKey != null &&
                                      book.coverAssetKey!.isNotEmpty
                                  ? CoverImageService.loadImage(
                                      book.coverAssetKey!,
                                    )
                                  : Future.value(null),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox(
                                    width: 48,
                                    height: 70,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      child: Icon(
                                        Icons.menu_book,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                                final Uint8List? coverBytes =
                                    snapshot.data;
                                return coverBytes != null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        child: Image.memory(
                                          coverBytes,
                                          width: 48,
                                          height: 70,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 75,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                          Icons.menu_book,
                                          size: 28,
                                          color: Colors.white,
                                        ),
                                      );
                              },
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              book.authors.isEmpty
                                  ? 'Unknown author'
                                  : book.authors,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          loading: () => const SliverFillRemaining(
            child: SizedBox(
              height: 110,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stack) => SliverFillRemaining(
            child: SizedBox(
              height: 110,
              child: Center(
                child: Text(
                  'Error loading books: $error',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}