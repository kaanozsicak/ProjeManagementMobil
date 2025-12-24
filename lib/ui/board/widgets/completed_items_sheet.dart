import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../shared/widgets/widgets.dart';
import 'item_card.dart';

/// Bottom sheet showing completed items
class CompletedItemsSheet extends ConsumerWidget {
  final String workspaceId;

  const CompletedItemsSheet({
    super.key,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedAsync = ref.watch(completedItemsStreamProvider(workspaceId));

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      '✅',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tamamlananlar',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    completedAsync.when(
                      data: (items) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${items.length}',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),

              // Content
              Expanded(
                child: completedAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const Center(
                        child: EmptyStateWidget(
                          icon: Icons.check_circle_outline,
                          title: 'Henüz tamamlanan yok',
                          subtitle:
                              'Görevleri tamamladıkça burada görünecek',
                        ),
                      );
                    }

                    // Group by date
                    final grouped = _groupByDate(items);

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: grouped.length,
                      itemBuilder: (context, index) {
                        final entry = grouped.entries.elementAt(index);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date header
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                entry.key,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            // Items
                            ...entry.value.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: ItemCard(
                                    item: item,
                                    workspaceId: workspaceId,
                                  ),
                                )),
                          ],
                        );
                      },
                    );
                  },
                  loading: () =>
                      const LoadingWidget(message: 'Yükleniyor...'),
                  error: (error, _) => AppErrorWidget(
                    message: 'Yüklenemedi: $error',
                    onRetry: () {
                      ref.invalidate(completedItemsStreamProvider(workspaceId));
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, List<Item>> _groupByDate(List<Item> items) {
    final Map<String, List<Item>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final item in items) {
      final itemDate = DateTime(
        item.updatedAt.year,
        item.updatedAt.month,
        item.updatedAt.day,
      );

      String key;
      if (itemDate == today) {
        key = 'Bugün';
      } else if (itemDate == yesterday) {
        key = 'Dün';
      } else if (itemDate.isAfter(today.subtract(const Duration(days: 7)))) {
        key = 'Bu Hafta';
      } else {
        key = '${itemDate.day}/${itemDate.month}/${itemDate.year}';
      }

      grouped.putIfAbsent(key, () => []).add(item);
    }

    return grouped;
  }
}
