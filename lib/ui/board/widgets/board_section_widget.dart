import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import 'item_card.dart';
import 'item_detail_dialog.dart';

/// A board section widget (like Keep sections)
class BoardSectionWidget extends ConsumerWidget {
  final BoardSection section;
  final String workspaceId;
  final VoidCallback onAddItem;

  const BoardSectionWidget({
    super.key,
    required this.section,
    required this.workspaceId,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isIdeaSection = section.type == ItemType.idea;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getSectionColor(section.type).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  section.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Item count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getSectionColor(section.type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${section.count}',
                    style: TextStyle(
                      color: _getSectionColor(section.type),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Add button
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 20,
                  onPressed: onAddItem,
                  tooltip: 'Ekle',
                  color: _getSectionColor(section.type),
                ),
              ],
            ),
          ),

          // Idea section special info banner
          if (isIdeaSection && section.items.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.amber.shade50,
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fikirleri görevleştirmek için üzerine tıklayın',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Items list
          if (section.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                isIdeaSection 
                    ? 'Henüz fikir yok. Yeni fikirlerinizi buraya ekleyin!'
                    : 'Bu bölümde henüz item yok',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              itemCount: section.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = section.items[index];
                return isIdeaSection 
                    ? _IdeaCard(item: item, workspaceId: workspaceId)
                    : ItemCard(item: item, workspaceId: workspaceId);
              },
            ),
        ],
      ),
    );
  }

  Color _getSectionColor(ItemType type) {
    switch (type) {
      case ItemType.activeTask:
        return Colors.blue;
      case ItemType.bug:
        return Colors.red;
      case ItemType.logic:
        return Colors.purple;
      case ItemType.idea:
        return Colors.amber;
    }
  }
}

/// Special card for ideas with quick convert action
class _IdeaCard extends ConsumerWidget {
  final Item item;
  final String workspaceId;

  const _IdeaCard({
    required this.item,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: Colors.amber.shade50,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showItemDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

              // Quick convert buttons
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Görevleştir:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _QuickConvertChip(
                    emoji: '🎯',
                    label: 'Görev',
                    color: Colors.blue,
                    onTap: () => _convertTo(context, ref, ItemType.activeTask),
                  ),
                  const SizedBox(width: 4),
                  _QuickConvertChip(
                    emoji: '🐛',
                    label: 'Bug',
                    color: Colors.red,
                    onTap: () => _convertTo(context, ref, ItemType.bug),
                  ),
                  const SizedBox(width: 4),
                  _QuickConvertChip(
                    emoji: '⚙️',
                    label: 'Logic',
                    color: Colors.purple,
                    onTap: () => _convertTo(context, ref, ItemType.logic),
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

  Future<void> _convertTo(BuildContext context, WidgetRef ref, ItemType newType) async {
    final notifier = ref.read(itemNotifierProvider(workspaceId).notifier);
    
    await notifier.convertType(
      item.id,
      newType,
      itemTitle: item.title,
      oldType: item.type,
    );
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newType.emoji} "${item.title}" → ${newType.displayName}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Small chip for quick conversion
class _QuickConvertChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickConvertChip({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 10)),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
