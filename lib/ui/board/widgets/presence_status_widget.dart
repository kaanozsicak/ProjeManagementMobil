import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';

/// Widget for updating user's presence status
class PresenceStatusWidget extends ConsumerWidget {
  final String workspaceId;

  const PresenceStatusWidget({
    super.key,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myPresence = ref.watch(myPresenceProvider(workspaceId));
    final presenceState = ref.watch(presenceNotifierProvider(workspaceId));
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showStatusDialog(context, ref, myPresence),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: myPresence != null
                      ? _getStatusColor(myPresence.status)
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),

              // Status text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      myPresence?.status.displayName ?? 'Durumunu Ayarla',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (myPresence?.hasMessage == true)
                      Text(
                        myPresence!.message!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Edit icon
              Icon(
                Icons.edit_outlined,
                size: 18,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusDialog(
    BuildContext context,
    WidgetRef ref,
    Presence? currentPresence,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _StatusEditSheet(
        workspaceId: workspaceId,
        currentPresence: currentPresence,
      ),
    );
  }

  Color _getStatusColor(PresenceStatus status) {
    switch (status) {
      case PresenceStatus.idle:
        return Colors.green;
      case PresenceStatus.active:
        return Colors.blue;
      case PresenceStatus.busy:
        return Colors.red;
      case PresenceStatus.away:
        return Colors.amber;
    }
  }
}

/// Bottom sheet for editing presence status
class _StatusEditSheet extends ConsumerStatefulWidget {
  final String workspaceId;
  final Presence? currentPresence;

  const _StatusEditSheet({
    required this.workspaceId,
    this.currentPresence,
  });

  @override
  ConsumerState<_StatusEditSheet> createState() => _StatusEditSheetState();
}

class _StatusEditSheetState extends ConsumerState<_StatusEditSheet> {
  late PresenceStatus _selectedStatus;
  late TextEditingController _messageController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentPresence?.status ?? PresenceStatus.idle;
    _messageController =
        TextEditingController(text: widget.currentPresence?.message ?? '');
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSubmitting = true);

    final notifier =
        ref.read(presenceNotifierProvider(widget.workspaceId).notifier);
    final success = await notifier.updatePresence(
      status: _selectedStatus,
      message:
          _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Durumunu Güncelle',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Status options
            Text(
              'Durum',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PresenceStatus.values.map((status) {
                final isSelected = status == _selectedStatus;
                return ChoiceChip(
                  selected: isSelected,
                  label: Text('${status.emoji} ${status.displayName}'),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedStatus = status);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Message input
            Text(
              'Mesaj (opsiyonel)',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ne yapıyorsun? (örn: Mama yiyor 🍕)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.message_outlined),
              ),
              maxLength: 50,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),

            // Quick message suggestions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickMessageChip(
                  text: '☕ Mola',
                  onTap: () => _messageController.text = '☕ Mola',
                ),
                _QuickMessageChip(
                  text: '🍕 Yemekte',
                  onTap: () => _messageController.text = '🍕 Yemekte',
                ),
                _QuickMessageChip(
                  text: '📞 Toplantıda',
                  onTap: () => _messageController.text = '📞 Toplantıda',
                ),
                _QuickMessageChip(
                  text: '🎧 Deep work',
                  onTap: () => _messageController.text = '🎧 Deep work',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kaydet'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _QuickMessageChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _QuickMessageChip({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(text),
      onPressed: onTap,
    );
  }
}
