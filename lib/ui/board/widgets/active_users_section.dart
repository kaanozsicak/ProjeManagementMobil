import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../shared/theme/app_colors.dart';
import '../widgets/item_card.dart';

/// Active users section - shows who's working on what
class ActiveUsersSection extends ConsumerWidget {
  final String workspaceId;

  const ActiveUsersSection({
    super.key,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeUsers = ref.watch(activeUsersViewProvider(workspaceId));
    final theme = Theme.of(context);

    if (activeUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Text('👥', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Şu Anda Kimde?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${activeUsers.length}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Users list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: activeUsers.length,
            itemBuilder: (context, index) {
              final userData = activeUsers[index];
              // Show all users who are members
              return _ActiveUserCard(
                userData: userData,
                workspaceId: workspaceId,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Card showing a user's presence and their active items
class _ActiveUserCard extends ConsumerWidget {
  final ActiveUserData userData;
  final String workspaceId;

  const _ActiveUserCard({
    required this.userData,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(userStreamProvider(userData.userId));
    final presence = userData.presence;

    return userAsync.when(
      data: (user) {
        final userName = user?.displayName ?? 'Bilinmeyen Kullanıcı';

        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User header with presence
              ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Status indicator dot
                    if (presence != null)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _getStatusColor(presence.status),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  presence != null
                      ? (presence.hasMessage
                          ? presence.message!
                          : presence.status.displayName)
                      : 'Durum belirlenmedi',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                trailing: userData.hasActiveItems
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${userData.activeItemCount} iş',
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),

              // Active items
              if (userData.hasActiveItems) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: userData.activeItems
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: ItemCard(
                                item: item,
                                workspaceId: workspaceId,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => Card(
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.surfaceContainerHigh,
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          title: const Text('Yükleniyor...'),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Color _getStatusColor(PresenceStatus status) {
    switch (status) {
      case PresenceStatus.idle:
        return AppColors.presenceIdle;
      case PresenceStatus.active:
        return AppColors.presenceActive;
      case PresenceStatus.busy:
        return AppColors.presenceBusy;
      case PresenceStatus.away:
        return AppColors.presenceAway;
    }
  }
}
