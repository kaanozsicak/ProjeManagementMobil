import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../shared/theme/app_motion.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import 'animated_item_card.dart';

/// Bottom sheet showing completed items with animations
class CompletedItemsSheet extends ConsumerWidget {
  final String workspaceId;

  const CompletedItemsSheet({
    super.key,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedAsync = ref.watch(completedItemsStreamProvider(workspaceId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusLg),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: colorScheme.onTertiaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Tamamlananlar',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    completedAsync.when(
                      data: (items) => AnimatedContainer(
                        duration: AppMotion.durationFast,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Text(
                          '${items.length}',
                          style: TextStyle(
                            color: colorScheme.onTertiaryContainer,
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
              Divider(
                height: AppSpacing.lg,
                color: colorScheme.outlineVariant,
              ),

              // Content
              Expanded(
                child: completedAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: colorScheme.tertiaryContainer.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_circle_outline,
                                size: 48,
                                color: colorScheme.tertiary.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Henüz tamamlanan yok',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Görevleri tamamladıkça burada görünecek',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Group by date
                    final grouped = _groupByDate(items);

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: grouped.length,
                      itemBuilder: (context, index) {
                        final entry = grouped.entries.elementAt(index);
                        return _DateGroup(
                          date: entry.key,
                          items: entry.value,
                          workspaceId: workspaceId,
                          groupIndex: index,
                        );
                      },
                    );
                  },
                  loading: () => const SkeletonCompletedList(),
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

/// Date group with header and animated items
class _DateGroup extends StatelessWidget {
  final String date;
  final List<Item> items;
  final String workspaceId;
  final int groupIndex;

  const _DateGroup({
    required this.date,
    required this.items,
    required this.workspaceId,
    required this.groupIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 200 + (groupIndex * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header with icon
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Icon(
                  _getDateIcon(date),
                  size: 14,
                  color: colorScheme.outline,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  date,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Container(
                    height: 1,
                    color: colorScheme.outlineVariant,
                  ),
                ),
              ],
            ),
          ),
          // Items
          ...items.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AnimatedItemCard(
                item: entry.value,
                workspaceId: workspaceId,
                index: entry.key,
                animate: false, // Already animated by parent
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getDateIcon(String date) {
    switch (date) {
      case 'Bugün':
        return Icons.today;
      case 'Dün':
        return Icons.history;
      case 'Bu Hafta':
        return Icons.date_range;
      default:
        return Icons.calendar_today;
    }
  }
}
