import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dandelion/features/dashboard/dashboard_models.dart';
import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/insights/dashboard_providers.dart';
import 'package:dandelion/shared/services/cover_image_service.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DashboardMetrics> metricsAsync = ref.watch(
      dashboardMetricsProvider,
    );
    final AsyncValue<List<MapEntry<String, int>>> topGenresAsync = ref.watch(
      topGenresProvider(5),
    );
    final AsyncValue<List<Book>> currentlyReadingAsync = ref.watch(
      currentlyReadingBooksProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: metricsAsync.when(
        data: (metrics) => CustomScrollView(
          slivers: [
            // Summary cards
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: _buildSummaryCards(context, metrics),
              ),
            ),
            // Currently reading
            if (metrics.currentlyReading > 0)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: const Text(
                    'Currently Reading',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
            if (metrics.currentlyReading > 0)
              currentlyReadingAsync.when(
                data: (books) => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: books.isEmpty
                      ? const SliverToBoxAdapter(child: SizedBox.shrink())
                      : SliverList.builder(
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            final book = books[index];
                            return Card(
                              child: ListTile(
                                leading: FutureBuilder<Uint8List?>(
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
                                      return const CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        child: Icon(
                                          Icons.menu_book,
                                          color: Colors.white,
                                        ),
                                      );
                                    }
                                    final Uint8List? coverBytes = snapshot.data;
                                    return coverBytes != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: Image.memory(
                                              coverBytes,
                                              width: 44,
                                              height: 64,
                                              fit: BoxFit.cover,
                                              semanticLabel:
                                                  'Cover of ${book.title}',
                                            ),
                                          )
                                        : CircleAvatar(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            child: Icon(
                                              Icons.menu_book,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                            ),
                                          );
                                  },
                                ),
                                title: Text(book.title),
                                subtitle: Text(
                                  book.authors.isEmpty
                                      ? 'Unknown author'
                                      : book.authors,
                                ),
                              ),
                            );
                          },
                        ),
                ),
                loading: () => const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Center(child: Text('Error: $error')),
                  ),
                ),
              ),
            // Top genres
            if (metrics.genreCounts.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: const Text(
                    'Top Genres',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
            if (metrics.genreCounts.isNotEmpty)
              topGenresAsync.when(
                data: (topGenres) => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: topGenres.isEmpty
                      ? const SliverToBoxAdapter(child: SizedBox.shrink())
                      : SliverList.builder(
                          itemCount: topGenres.length,
                          itemBuilder: (context, index) {
                            final entry = topGenres[index];
                            return ListTile(
                              leading: const Icon(Icons.label),
                              title: Text(entry.key),
                              trailing: Text('${entry.value} books'),
                            );
                          },
                        ),
                ),
                loading: () => const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Center(child: Text('Error: $error')),
                  ),
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                'Could not load insights: $error',
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
