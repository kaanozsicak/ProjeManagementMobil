import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../repositories/repositories.dart';
import '../../shared/widgets/widgets.dart';

/// Activity log screen - shows recent activities
class ActivityLogScreen extends ConsumerWidget {
  final String workspaceId;

  const ActivityLogScreen({
    super.key,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(recentActivitiesStreamProvider(workspaceId));
    final groupedActivities = ref.watch(groupedActivitiesProvider(workspaceId));

    // Mark as seen when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activityNotifierProvider.notifier).markAsSeen();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Son Hareketler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: () {
              ref.invalidate(recentActivitiesStreamProvider(workspaceId));
            },
          ),
        ],
      ),
      body: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.history,
              title: 'Henüz aktivite yok',
              subtitle: 'İlk item\'ı ekleyince burası dolmaya başlayacak.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedActivities.length,
            itemBuilder: (context, index) {
              final group = groupedActivities[index];
              return _ActivityGroupWidget(
                group: group,
                workspaceId: workspaceId,
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Aktiviteler yükleniyor...'),
        error: (error, _) => AppErrorWidget(
          message: 'Aktiviteler yüklenemedi: $error',
          onRetry: () {
            ref.invalidate(recentActivitiesStreamProvider(workspaceId));
          },
        ),
      ),
    );
  }
}

/// Activity group widget (grouped by date)
class _ActivityGroupWidget extends StatelessWidget {
  final ActivityGroup group;
  final String workspaceId;

  const _ActivityGroupWidget({
    required this.group,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            group.label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Activities
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: group.activities.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _ActivityTile(
                activity: group.activities[index],
                workspaceId: workspaceId,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Single activity tile
class _ActivityTile extends StatelessWidget {
  final ItemActivity activity;
  final String workspaceId;

  const _ActivityTile({
    required this.activity,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getActionColor(activity.action).withOpacity(0.2),
        child: Text(
          activity.action.emoji,
          style: const TextStyle(fontSize: 18),
        ),
      ),
      title: Text(
        activity.getDescription(),
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Text(
        _formatTime(activity.createdAt),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
      trailing: _buildActionIcon(activity.action),
    );
  }

  Widget _buildActionIcon(ActivityAction action) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getActionColor(action).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getActionIconData(action),
        size: 16,
        color: _getActionColor(action),
      ),
    );
  }

  Color _getActionColor(ActivityAction action) {
    switch (action) {
      case ActivityAction.created:
        return Colors.green;
      case ActivityAction.deleted:
        return Colors.red;
      case ActivityAction.assigned:
      case ActivityAction.unassigned:
        return Colors.blue;
      case ActivityAction.stateChanged:
        return Colors.orange;
      case ActivityAction.typeChanged:
        return Colors.purple;
      case ActivityAction.priorityChanged:
        return Colors.amber;
      case ActivityAction.contentEdited:
      case ActivityAction.updated:
        return Colors.grey;
    }
  }

  IconData _getActionIconData(ActivityAction action) {
    switch (action) {
      case ActivityAction.created:
        return Icons.add_circle_outline;
      case ActivityAction.deleted:
        return Icons.delete_outline;
      case ActivityAction.assigned:
        return Icons.person_add_outlined;
      case ActivityAction.unassigned:
        return Icons.person_remove_outlined;
      case ActivityAction.stateChanged:
        return Icons.swap_horiz;
      case ActivityAction.typeChanged:
        return Icons.label_outline;
      case ActivityAction.priorityChanged:
        return Icons.flag_outlined;
      case ActivityAction.contentEdited:
      case ActivityAction.updated:
        return Icons.edit_outlined;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Az önce';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} dakika önce';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} saat önce';
    } else {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
  }
}
