import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../repositories/repositories.dart';
import 'item_detail_dialog.dart';

/// A card widget for displaying an item
class ItemCard extends ConsumerWidget {
  final Item item;
  final String workspaceId;

  const ItemCard({
    super.key,
    required this.item,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showItemDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with state indicator
              Row(
                children: [
                  // State indicator
                  _StateIndicator(state: item.state),
                  const SizedBox(width: 8),
                  // Title
                  Expanded(
                    child: Text(
                      item.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Priority indicator
                  if (item.priority == ItemPriority.high)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        item.priority.emoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                ],
              ),

              // Description preview
              if (item.description != null && item.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Bottom row with assignee and quick actions
              const SizedBox(height: 8),
              Row(
                children: [
                  // Assignee
                  if (item.isAssigned)
                    _AssigneeChip(
                      userId: item.assigneeUserId!,
                      workspaceId: workspaceId,
                    )
                  else
                    Chip(
                      label: const Text(
                        'Atanmamış',
                        style: TextStyle(fontSize: 11),
                      ),
                      avatar: const Icon(Icons.person_outline, size: 14),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),

                  const Spacer(),

                  // Quick state change buttons
                  _QuickStateButtons(
                    item: item,
                    workspaceId: workspaceId,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ItemDetailDialog(
        item: item,
        workspaceId: workspaceId,
      ),
    );
  }
}

/// State indicator dot
class _StateIndicator extends StatelessWidget {
  final ItemState state;

  const _StateIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getColor(),
      ),
    );
  }

  Color _getColor() {
    switch (state) {
      case ItemState.todo:
        return Colors.grey;
      case ItemState.doing:
        return Colors.blue;
      case ItemState.done:
        return Colors.green;
    }
  }
}

/// Assignee chip with user info
class _AssigneeChip extends ConsumerWidget {
  final String userId;
  final String workspaceId;

  const _AssigneeChip({
    required this.userId,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRepo = ref.read(userRepositoryProvider);

    return FutureBuilder(
      future: userRepo.getUser(userId),
      builder: (context, snapshot) {
        final userName = snapshot.data?.displayName ?? '...';
        return Chip(
          label: Text(
            userName,
            style: const TextStyle(fontSize: 11),
          ),
          avatar: CircleAvatar(
            radius: 10,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 10),
            ),
          ),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      },
    );
  }
}

/// Quick state change buttons
class _QuickStateButtons extends ConsumerWidget {
  final Item item;
  final String workspaceId;

  const _QuickStateButtons({
    required this.item,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(itemNotifierProvider(workspaceId).notifier);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Start/Stop working
        if (item.state == ItemState.todo)
          IconButton(
            icon: const Icon(Icons.play_arrow, size: 18),
            tooltip: 'Başla',
            onPressed: () => notifier.startWorking(
              item.id, 
              itemTitle: item.title, 
              oldState: item.state,
            ),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),

        if (item.state == ItemState.doing)
          IconButton(
            icon: const Icon(Icons.check, size: 18, color: Colors.green),
            tooltip: 'Tamamla',
            onPressed: () => notifier.markAsDone(
              item.id,
              itemTitle: item.title,
              oldState: item.state,
            ),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
      ],
    );
  }
}
