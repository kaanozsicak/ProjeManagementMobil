import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../shared/theme/app_motion.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_theme.dart';

/// Modern bottom sheet for creating a new item
class ItemCreateSheet extends ConsumerStatefulWidget {
  final String workspaceId;
  final ItemType? defaultType;

  const ItemCreateSheet({
    super.key,
    required this.workspaceId,
    this.defaultType,
  });

  @override
  ConsumerState<ItemCreateSheet> createState() => _ItemCreateSheetState();
}

class _ItemCreateSheetState extends ConsumerState<ItemCreateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocusNode = FocusNode();

  late ItemType _selectedType;
  ItemPriority _selectedPriority = ItemPriority.medium;
  String? _selectedAssignee;
  bool _isSubmitting = false;
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.defaultType ?? ItemType.activeTask;
    
    // Auto-focus title field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    HapticFeedback.lightImpact();

    final notifier =
        ref.read(itemNotifierProvider(widget.workspaceId).notifier);

    final item = await notifier.createItem(
      type: _selectedType,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      assigneeUserId: _selectedAssignee,
      priority: _selectedPriority,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (item != null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(_selectedType.emoji),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('"${item.title}" eklendi')),
            ],
          ),
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
    final itemState = ref.watch(itemNotifierProvider(widget.workspaceId));

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
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

              // Header
              _buildHeader(colorScheme),

              // Divider
              Divider(color: colorScheme.outlineVariant, height: 1),

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Type selector as chips
                        _buildTypeSelector(colorScheme),
                        const SizedBox(height: AppSpacing.lg),

                        // Title input with animation
                        TextFormField(
                          controller: _titleController,
                          focusNode: _titleFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Başlık *',
                            hintText: 'Kısa ve açıklayıcı bir başlık',
                            prefixIcon: const Icon(Icons.title),
                            suffixIcon: _titleController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _titleController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                          ),
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Başlık gerekli';
                            }
                            if (value.trim().length < 2) {
                              return 'En az 2 karakter olmalı';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Description input
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Açıklama',
                            hintText: 'Detaylı açıklama (opsiyonel)',
                            prefixIcon: Icon(Icons.description),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                          textInputAction: TextInputAction.newline,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Advanced options toggle
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _showAdvanced = !_showAdvanced);
                          },
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _showAdvanced
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  'Gelişmiş Seçenekler',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Advanced options with animation
                        AnimatedSize(
                          duration: AppMotion.durationMedium,
                          curve: AppMotion.curveStandard,
                          child: _showAdvanced
                              ? _buildAdvancedOptions(membersAsync)
                              : const SizedBox.shrink(),
                        ),

                        // Error message
                        if (itemState.error != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: colorScheme.onErrorContainer,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    itemState.error!,
                                    style: TextStyle(
                                      color: colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
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
          AnimatedContainer(
            duration: AppMotion.durationFast,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: _getTypeColor(colorScheme).withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              _selectedType.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yeni ${_selectedType.displayName}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                'Hızlıca ekle ve daha sonra düzenle',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category_outlined,
                size: 16, color: colorScheme.outline),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Tür',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: ItemType.values.map((type) {
            final isSelected = type == _selectedType;
            final color = _getTypeColorFor(type, colorScheme);

            return AnimatedContainer(
              duration: AppMotion.durationFast,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedType = type);
                },
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: AnimatedContainer(
                  duration: AppMotion.durationFast,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.2)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(type.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        type.displayName,
                        style: TextStyle(
                          color: isSelected
                              ? color
                              : colorScheme.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions(
      AsyncValue<List<Membership>> membersAsync) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        children: [
          // Priority selector
          DropdownButtonFormField<ItemPriority>(
            value: _selectedPriority,
            decoration: const InputDecoration(
              labelText: 'Öncelik',
              prefixIcon: Icon(Icons.flag),
            ),
            items: ItemPriority.values.map((priority) {
              return DropdownMenuItem(
                value: priority,
                child: Text('${priority.emoji} ${priority.displayName}'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                HapticFeedback.selectionClick();
                setState(() => _selectedPriority = value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Assignee selector
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
                HapticFeedback.selectionClick();
                setState(() => _selectedAssignee = value);
              },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Text(
                'Üyeler yüklenemedi',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ColorScheme colorScheme) {
    final isValid = _titleController.text.trim().length >= 2;

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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed:
                  _isSubmitting ? null : () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: AnimatedContainer(
              duration: AppMotion.durationFast,
              child: FilledButton.icon(
                onPressed: (_isSubmitting || !isValid) ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_rounded),
                label: Text(_isSubmitting ? 'Ekleniyor...' : 'Ekle'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(ColorScheme colorScheme) {
    return _getTypeColorFor(_selectedType, colorScheme);
  }

  Color _getTypeColorFor(ItemType type, ColorScheme colorScheme) {
    switch (type) {
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

/// Helper function to show the create sheet
void showItemCreateSheet(
  BuildContext context, {
  required String workspaceId,
  ItemType? defaultType,
}) {
  HapticFeedback.selectionClick();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ItemCreateSheet(
      workspaceId: workspaceId,
      defaultType: defaultType,
    ),
  );
}
