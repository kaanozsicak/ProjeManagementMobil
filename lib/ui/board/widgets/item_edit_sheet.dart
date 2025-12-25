import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../shared/theme/app_motion.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_theme.dart';

/// Modern bottom sheet for viewing and editing item details
class ItemEditSheet extends ConsumerStatefulWidget {
  final Item item;
  final String workspaceId;

  const ItemEditSheet({
    super.key,
    required this.item,
    required this.workspaceId,
  });

  @override
  ConsumerState<ItemEditSheet> createState() => _ItemEditSheetState();
}

class _ItemEditSheetState extends ConsumerState<ItemEditSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late ItemType _selectedType;
  late ItemPriority _selectedPriority;
  late ItemState _selectedState;
  String? _selectedAssignee;
  bool _isEditing = false;
  bool _isSubmitting = false;
  bool _hasChanges = false;

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
    _hasChanges = false;
  }

  void _markAsChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
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
    HapticFeedback.lightImpact();

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

    final notifier =
        ref.read(itemNotifierProvider(widget.workspaceId).notifier);
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
    final colorScheme = Theme.of(context).colorScheme;
    
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_forever,
              size: 48,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Item\'ı Sil',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '"${widget.item.title}" silinecek.\nBu işlem geri alınamaz.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onErrorContainer,
                      side: BorderSide(color: colorScheme.onErrorContainer),
                    ),
                    child: const Text('İptal'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      Navigator.of(context).pop(true);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                    child: const Text('Sil'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);

    final notifier =
        ref.read(itemNotifierProvider(widget.workspaceId).notifier);
    final success =
        await notifier.deleteItem(widget.item.id, itemTitle: widget.item.title);

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
    final colorScheme = theme.colorScheme;
    final membersAsync =
        ref.watch(workspaceMembersProvider(widget.workspaceId));

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header with title and actions
              _buildHeader(colorScheme),

              // Divider
              Divider(color: colorScheme.outlineVariant, height: 1),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: AnimatedSwitcher(
                    duration: AppMotion.durationMedium,
                    child: _isEditing
                        ? _buildEditMode(membersAsync)
                        : _buildViewMode(theme),
                  ),
                ),
              ),

              // Bottom action bar
              _buildBottomBar(colorScheme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Type emoji with background
          AnimatedContainer(
            duration: AppMotion.durationFast,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: _getTypeColor(colorScheme).withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              _isEditing ? _selectedType.emoji : widget.item.type.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Title or "Edit mode" indicator
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.durationFast,
              child: _isEditing
                  ? Text(
                      'Düzenleme Modu',
                      key: const ValueKey('edit'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    )
                  : Text(
                      widget.item.title,
                      key: const ValueKey('view'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
            ),
          ),

          // Edit/Close toggle
          if (!_isEditing)
            IconButton.filled(
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _isEditing = true);
              },
              icon: const Icon(Icons.edit_outlined, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
              ),
            )
          else
            IconButton.outlined(
              onPressed: () {
                _resetToOriginal();
                setState(() => _isEditing = false);
              },
              icon: const Icon(Icons.close, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildViewMode(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        if (widget.item.description != null &&
            widget.item.description!.isNotEmpty) ...[
          _SectionLabel(label: 'Açıklama', icon: Icons.description_outlined),
          const SizedBox(height: AppSpacing.xs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              widget.item.description!,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Status chips
        _SectionLabel(label: 'Durum & Öncelik', icon: Icons.info_outline),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _StatusChip(
              emoji: widget.item.state.emoji,
              label: widget.item.state.displayName,
              color: _getStateColor(widget.item.state, colorScheme),
            ),
            _StatusChip(
              emoji: widget.item.priority.emoji,
              label: widget.item.priority.displayName,
              color: _getPriorityColor(widget.item.priority, colorScheme),
            ),
            if (widget.item.isAssigned)
              _AnimatedAssigneeChip(userId: widget.item.assigneeUserId!),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Quick Actions
        _SectionLabel(label: 'Hızlı İşlemler', icon: Icons.flash_on_outlined),
        const SizedBox(height: AppSpacing.sm),
        _QuickActionsSection(
          item: widget.item,
          workspaceId: widget.workspaceId,
          onStateChanged: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Metadata
        _SectionLabel(label: 'Bilgi', icon: Icons.schedule_outlined),
        const SizedBox(height: AppSpacing.sm),
        _MetadataCard(item: widget.item),
      ],
    );
  }

  Widget _buildEditMode(AsyncValue<List<Membership>> membersAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Başlık',
            prefixIcon: Icon(Icons.title),
          ),
          onChanged: (_) => _markAsChanged(),
        ),
        const SizedBox(height: AppSpacing.md),

        // Description
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Açıklama',
            prefixIcon: Icon(Icons.description),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          onChanged: (_) => _markAsChanged(),
        ),
        const SizedBox(height: AppSpacing.md),

        // Type & State row
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<ItemType>(
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
                  if (value != null) {
                    setState(() => _selectedType = value);
                    _markAsChanged();
                  }
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: DropdownButtonFormField<ItemState>(
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
                  if (value != null) {
                    setState(() => _selectedState = value);
                    _markAsChanged();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

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
            if (value != null) {
              setState(() => _selectedPriority = value);
              _markAsChanged();
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),

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
              _markAsChanged();
            },
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('Üyeler yüklenemedi'),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.durationFast,
        child: _isEditing
            ? Row(
                key: const ValueKey('edit-actions'),
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              _resetToOriginal();
                              setState(() => _isEditing = false);
                            },
                      icon: const Icon(Icons.close),
                      label: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: (_isSubmitting || !_hasChanges)
                          ? null
                          : _saveChanges,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSubmitting ? 'Kaydediliyor...' : 'Kaydet'),
                    ),
                  ),
                ],
              )
            : Row(
                key: const ValueKey('view-actions'),
                children: [
                  OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _deleteItem,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Sil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error.withOpacity(0.5)),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Kapat'),
                  ),
                ],
              ),
      ),
    );
  }

  Color _getTypeColor(ColorScheme colorScheme) {
    switch (_selectedType) {
      case ItemType.activeTask:
        return colorScheme.primary;
      case ItemType.bug:
        return colorScheme.error;
      case ItemType.logic:
        return colorScheme.tertiary;
      case ItemType.idea:
        return Colors.amber;
    }
  }

  Color _getStateColor(ItemState state, ColorScheme colorScheme) {
    switch (state) {
      case ItemState.todo:
        return colorScheme.outline;
      case ItemState.doing:
        return colorScheme.primary;
      case ItemState.done:
        return colorScheme.tertiary;
    }
  }

  Color _getPriorityColor(ItemPriority priority, ColorScheme colorScheme) {
    switch (priority) {
      case ItemPriority.low:
        return colorScheme.outline;
      case ItemPriority.medium:
        return colorScheme.secondary;
      case ItemPriority.high:
        return colorScheme.error;
    }
  }
}

// Helper widgets

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.outline),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.outline,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _StatusChip({
    required this.emoji,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedAssigneeChip extends ConsumerWidget {
  final String userId;

  const _AnimatedAssigneeChip({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRepo = ref.read(userRepositoryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder(
      future: userRepo.getUser(userId),
      builder: (context, snapshot) {
        final userName = snapshot.data?.displayName ?? '...';
        final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: colorScheme.primary,
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                userName,
                style: TextStyle(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MemberDropdownItem extends ConsumerWidget {
  final String userId;

  const _MemberDropdownItem({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRepo = ref.read(userRepositoryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder(
      future: userRepo.getUser(userId),
      builder: (context, snapshot) {
        final userName = snapshot.data?.displayName ?? 'Yükleniyor...';
        return Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(userName),
          ],
        );
      },
    );
  }
}

class _QuickActionsSection extends ConsumerWidget {
  final Item item;
  final String workspaceId;
  final VoidCallback onStateChanged;

  const _QuickActionsSection({
    required this.item,
    required this.workspaceId,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(itemNotifierProvider(workspaceId).notifier);
    final colorScheme = Theme.of(context).colorScheme;
    
    // Mevcut kullanıcı ID'si
    final currentUserId = ref.watch(firebaseAuthStateProvider).valueOrNull?.uid;
    
    // Görev atandıysa sadece atanan kişi tamamlayabilir
    final canComplete = item.assigneeUserId == null || 
                        item.assigneeUserId == currentUserId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // State change actions
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            if (item.state == ItemState.todo)
              _ActionButton(
                icon: Icons.play_arrow_rounded,
                label: 'Başla',
                color: colorScheme.primary,
                onPressed: () async {
                  HapticFeedback.selectionClick();
                  await notifier.startWorking(
                    item.id,
                    itemTitle: item.title,
                    oldState: item.state,
                  );
                  onStateChanged();
                },
              ),
            // Sadece atanan kişi veya atanmamışsa herkes tamamlayabilir
            if (item.state == ItemState.doing && canComplete)
              _ActionButton(
                icon: Icons.check_circle_outline,
                label: 'Tamamla',
                color: colorScheme.tertiary,
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await notifier.markAsDone(
                    item.id,
                    itemTitle: item.title,
                    oldState: item.state,
                  );
                  onStateChanged();
                },
              ),
            if (item.state != ItemState.todo)
              _ActionButton(
                icon: Icons.replay_rounded,
                label: 'Yapılacaklara',
                color: colorScheme.outline,
                onPressed: () async {
                  HapticFeedback.selectionClick();
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

        // Convert Idea to Task/Bug/Logic
        if (item.type == ItemType.idea) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Fikri Görevleştir',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _ConvertChip(
                emoji: ItemType.activeTask.emoji,
                label: 'Görev',
                color: colorScheme.primary,
                onTap: () =>
                    _convertTo(context, notifier, ItemType.activeTask),
              ),
              _ConvertChip(
                emoji: ItemType.bug.emoji,
                label: 'Bug',
                color: colorScheme.error,
                onTap: () => _convertTo(context, notifier, ItemType.bug),
              ),
              _ConvertChip(
                emoji: ItemType.logic.emoji,
                label: 'Logic',
                color: colorScheme.tertiary,
                onTap: () => _convertTo(context, notifier, ItemType.logic),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _convertTo(
      BuildContext context, dynamic notifier, ItemType newType) async {
    HapticFeedback.selectionClick();
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(newType.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Fikri Görevleştir',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '"${item.title}" fikri "${newType.displayName}" olarak görevleştirilecek.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('İptal'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(ctx).pop(true);
                    },
                    icon: Text(newType.emoji),
                    label: Text('${newType.displayName} Yap'),
                  ),
                ),
              ],
            ),
          ],
        ),
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
            content: Text(
                '${item.title} → ${newType.displayName} olarak görevleştirildi'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      onStateChanged();
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color.withOpacity(0.15),
        foregroundColor: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Text(label),
        ],
      ),
    );
  }
}

class _ConvertChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ConvertChip({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataCard extends ConsumerWidget {
  final Item item;

  const _MetadataCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userRepo = ref.read(userRepositoryProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Column(
        children: [
          _MetadataRow(
            icon: Icons.person_outline,
            label: 'Oluşturan',
            child: FutureBuilder(
              future: userRepo.getUser(item.createdBy),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data?.displayName ?? '...',
                  style: TextStyle(color: colorScheme.onSurface),
                );
              },
            ),
          ),
          const Divider(height: AppSpacing.md),
          _MetadataRow(
            icon: Icons.add_circle_outline,
            label: 'Oluşturulma',
            child: Text(
              _formatDate(item.createdAt),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          const Divider(height: AppSpacing.md),
          _MetadataRow(
            icon: Icons.update,
            label: 'Güncellenme',
            child: Text(
              _formatDate(item.updatedAt),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _MetadataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _MetadataRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.outline),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
