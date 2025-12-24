import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../repositories/repositories.dart';

/// Dialog for viewing and editing item details
class ItemDetailDialog extends ConsumerStatefulWidget {
  final Item item;
  final String workspaceId;

  const ItemDetailDialog({
    super.key,
    required this.item,
    required this.workspaceId,
  });

  @override
  ConsumerState<ItemDetailDialog> createState() => _ItemDetailDialogState();
}

class _ItemDetailDialogState extends ConsumerState<ItemDetailDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late ItemType _selectedType;
  late ItemPriority _selectedPriority;
  late ItemState _selectedState;
  String? _selectedAssignee;
  bool _isEditing = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _resetToOriginal();
  }

  void _resetToOriginal() {
    _titleController = TextEditingController(text: widget.item.title);
    _descriptionController =
        TextEditingController(text: widget.item.description ?? '');
    _selectedType = widget.item.type;
    _selectedPriority = widget.item.priority;
    _selectedState = widget.item.state;
    _selectedAssignee = widget.item.assigneeUserId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlık boş olamaz')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final updatedItem = widget.item.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      type: _selectedType,
      priority: _selectedPriority,
      state: _selectedState,
      assigneeUserId: _selectedAssignee,
      clearAssignee: _selectedAssignee == null,
    );

    final notifier = ref.read(itemNotifierProvider(widget.workspaceId).notifier);
    final success = await notifier.updateItem(updatedItem);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item güncellendi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Item\'ı Sil'),
        content: Text('"${widget.item.title}" silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    final notifier = ref.read(itemNotifierProvider(widget.workspaceId).notifier);
    final success = await notifier.deleteItem(widget.item.id, itemTitle: widget.item.title);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item silindi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(workspaceMembersProvider(widget.workspaceId));

    return AlertDialog(
      title: Row(
        children: [
          Text(widget.item.type.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(
            child: _isEditing
                ? const Text('Düzenle')
                : Text(
                    widget.item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Düzenle',
            ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isEditing) ...[
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Type
              DropdownButtonFormField<ItemType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tür',
                  prefixIcon: Icon(Icons.category),
                ),
                items: ItemType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text('${type.emoji} ${type.displayName}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 16),

              // State
              DropdownButtonFormField<ItemState>(
                value: _selectedState,
                decoration: const InputDecoration(
                  labelText: 'Durum',
                  prefixIcon: Icon(Icons.flag),
                ),
                items: ItemState.values.map((state) {
                  return DropdownMenuItem(
                    value: state,
                    child: Text('${state.emoji} ${state.displayName}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedState = value);
                },
              ),
              const SizedBox(height: 16),

              // Priority
              DropdownButtonFormField<ItemPriority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Öncelik',
                  prefixIcon: Icon(Icons.priority_high),
                ),
                items: ItemPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text('${priority.emoji} ${priority.displayName}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedPriority = value);
                },
              ),
              const SizedBox(height: 16),

              // Assignee
              membersAsync.when(
                data: (members) => DropdownButtonFormField<String?>(
                  value: _selectedAssignee,
                  decoration: const InputDecoration(
                    labelText: 'Atanan Kişi',
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Atanmamış'),
                    ),
                    ...members.map((member) {
                      return DropdownMenuItem(
                        value: member.userId,
                        child: _MemberDropdownItem(userId: member.userId),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedAssignee = value);
                  },
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Üyeler yüklenemedi'),
              ),
            ] else ...[
              // View mode
              if (widget.item.description != null &&
                  widget.item.description!.isNotEmpty) ...[
                Text(
                  'Açıklama',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 4),
                Text(widget.item.description!),
                const SizedBox(height: 16),
              ],

              // Info chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: Text(widget.item.state.emoji),
                    label: Text(widget.item.state.displayName),
                  ),
                  Chip(
                    avatar: Text(widget.item.priority.emoji),
                    label: Text(widget.item.priority.displayName),
                  ),
                  if (widget.item.isAssigned)
                    _AssigneeChip(userId: widget.item.assigneeUserId!),
                ],
              ),

              const SizedBox(height: 16),

              // Quick actions
              Text(
                'Hızlı İşlemler',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              _QuickActionsRow(
                item: widget.item,
                workspaceId: widget.workspaceId,
                onStateChanged: () => Navigator.of(context).pop(),
              ),

              const SizedBox(height: 16),

              // Metadata
              Text(
                'Bilgi',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              _MetadataRow(
                label: 'Oluşturan',
                child: _UserName(userId: widget.item.createdBy),
              ),
              _MetadataRow(
                label: 'Oluşturulma',
                child: Text(_formatDate(widget.item.createdAt)),
              ),
              _MetadataRow(
                label: 'Güncellenme',
                child: Text(_formatDate(widget.item.updatedAt)),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (_isEditing) ...[
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    _resetToOriginal();
                    setState(() => _isEditing = false);
                  },
            child: const Text('İptal'),
          ),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _saveChanges,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Kaydet'),
          ),
        ] else ...[
          TextButton.icon(
            onPressed: _isSubmitting ? null : _deleteItem,
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _MemberDropdownItem extends ConsumerWidget {
  final String userId;

  const _MemberDropdownItem({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRepo = ref.read(userRepositoryProvider);

    return FutureBuilder(
      future: userRepo.getUser(userId),
      builder: (context, snapshot) {
        final userName = snapshot.data?.displayName ?? 'Yükleniyor...';
        return Row(
          children: [
            CircleAvatar(
              radius: 12,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 10),
              ),
            ),
            const SizedBox(width: 8),
            Text(userName),
          ],
        );
      },
    );
  }
}

class _AssigneeChip extends ConsumerWidget {
  final String userId;

  const _AssigneeChip({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRepo = ref.read(userRepositoryProvider);

    return FutureBuilder(
      future: userRepo.getUser(userId),
      builder: (context, snapshot) {
        final userName = snapshot.data?.displayName ?? '...';
        return Chip(
          avatar: const Icon(Icons.person, size: 16),
          label: Text(userName),
        );
      },
    );
  }
}

class _UserName extends ConsumerWidget {
  final String userId;

  const _UserName({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRepo = ref.read(userRepositoryProvider);

    return FutureBuilder(
      future: userRepo.getUser(userId),
      builder: (context, snapshot) {
        return Text(snapshot.data?.displayName ?? '...');
      },
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _MetadataRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends ConsumerWidget {
  final Item item;
  final String workspaceId;
  final VoidCallback onStateChanged;

  const _QuickActionsRow({
    required this.item,
    required this.workspaceId,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(itemNotifierProvider(workspaceId).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // State change actions
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (item.state == ItemState.todo)
              ActionChip(
                avatar: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Başla'),
                onPressed: () async {
                  await notifier.startWorking(
                    item.id,
                    itemTitle: item.title,
                    oldState: item.state,
                  );
                  onStateChanged();
                },
              ),
            if (item.state == ItemState.doing)
              ActionChip(
                avatar: const Icon(Icons.check, size: 18, color: Colors.green),
                label: const Text('Tamamla'),
                onPressed: () async {
                  await notifier.markAsDone(
                    item.id,
                    itemTitle: item.title,
                    oldState: item.state,
                  );
                  onStateChanged();
                },
              ),
            if (item.state != ItemState.todo)
              ActionChip(
                avatar: const Icon(Icons.replay, size: 18),
                label: const Text('Yapılacaklara'),
                onPressed: () async {
                  await notifier.changeState(
                    item.id, 
                    ItemState.todo,
                    itemTitle: item.title,
                    oldState: item.state,
                  );
                  onStateChanged();
                },
              ),
          ],
        ),
        
        // Convert Idea to Task/Bug/Logic (Görevleştir)
        if (item.type == ItemType.idea) ...[
          const SizedBox(height: 12),
          Text(
            '💡 Fikri Görevleştir',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: Text(ItemType.activeTask.emoji),
                label: const Text('Göreve Çevir'),
                backgroundColor: Colors.blue.shade50,
                onPressed: () => _convertTo(context, notifier, ItemType.activeTask),
              ),
              ActionChip(
                avatar: Text(ItemType.bug.emoji),
                label: const Text('Bug Olarak İşaretle'),
                backgroundColor: Colors.red.shade50,
                onPressed: () => _convertTo(context, notifier, ItemType.bug),
              ),
              ActionChip(
                avatar: Text(ItemType.logic.emoji),
                label: const Text('Logic/Refactor'),
                backgroundColor: Colors.purple.shade50,
                onPressed: () => _convertTo(context, notifier, ItemType.logic),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _convertTo(BuildContext context, dynamic notifier, ItemType newType) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Text(newType.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            const Expanded(child: Text('Fikri Görevleştir')),
          ],
        ),
        content: Text(
          '"${item.title}" fikri "${newType.displayName}" olarak görevleştirilecek.\n\n'
          'Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: Text(newType.emoji),
            label: Text('${newType.displayName} Yap'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.convertType(
        item.id, 
        newType,
        itemTitle: item.title,
        oldType: item.type,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.title} → ${newType.displayName} olarak görevleştirildi'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      onStateChanged();
    }
  }
}
