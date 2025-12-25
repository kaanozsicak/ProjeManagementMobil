import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../repositories/repositories.dart';

/// Dialog for creating a new item
class ItemCreateDialog extends ConsumerStatefulWidget {
  final String workspaceId;
  final ItemType? defaultType;

  const ItemCreateDialog({
    super.key,
    required this.workspaceId,
    this.defaultType,
  });

  @override
  ConsumerState<ItemCreateDialog> createState() => _ItemCreateDialogState();
}

class _ItemCreateDialogState extends ConsumerState<ItemCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late ItemType _selectedType;
  ItemPriority _selectedPriority = ItemPriority.medium;
  String? _selectedAssignee;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.defaultType ?? ItemType.activeTask;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final notifier = ref.read(itemNotifierProvider(widget.workspaceId).notifier);

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
          content: Text('${_selectedType.emoji} "${item.title}" eklendi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(workspaceMembersProvider(widget.workspaceId));
    final itemState = ref.watch(itemNotifierProvider(widget.workspaceId));

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.add_task),
          SizedBox(width: 8),
          Text('Yeni Görev'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type selector
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
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Title input
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık *',
                  hintText: 'Kısa ve açıklayıcı bir başlık',
                  prefixIcon: Icon(Icons.title),
                ),
                textInputAction: TextInputAction.next,
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
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

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
                    setState(() => _selectedPriority = value);
                  }
                },
              ),
              const SizedBox(height: 16),

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
                    setState(() => _selectedAssignee = value);
                  },
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Üyeler yüklenemedi'),
              ),

              // Error message
              if (itemState.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          itemState.error!,
                          style: TextStyle(color: Colors.red.shade700),
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
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submit,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
          label: Text(_isSubmitting ? 'Ekleniyor...' : 'Ekle'),
        ),
      ],
    );
  }
}

/// Dropdown item showing member name
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
