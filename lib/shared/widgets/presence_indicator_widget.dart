import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Compact presence indicator for AppBar or other compact spaces
/// 
/// Shows current user's status with a dot and can be tapped to change status
class PresenceIndicatorWidget extends ConsumerWidget {
  final String workspaceId;
  final bool showLabel;

  const PresenceIndicatorWidget({
    super.key,
    required this.workspaceId,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch notifier directly for immediate updates after user action
    final notifierState = ref.watch(presenceNotifierProvider(workspaceId));
    Presence? myPresence = notifierState.currentPresence;
    // Fallback to stream if notifier hasn't loaded yet
    myPresence ??= ref.watch(myPresenceProvider(workspaceId));
    
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showStatusSheet(context, ref, myPresence),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: myPresence != null
                    ? _getStatusColor(myPresence.status)
                    : AppColors.presenceIdle,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (myPresence != null
                            ? _getStatusColor(myPresence.status)
                            : AppColors.presenceIdle)
                        .withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                myPresence?.status.displayName ?? 'Durum',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showStatusSheet(
    BuildContext context,
    WidgetRef ref,
    Presence? currentPresence,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _QuickStatusSheet(
        workspaceId: workspaceId,
        currentPresence: currentPresence,
      ),
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

/// Quick status selection sheet
class _QuickStatusSheet extends ConsumerStatefulWidget {
  final String workspaceId;
  final Presence? currentPresence;

  const _QuickStatusSheet({
    required this.workspaceId,
    this.currentPresence,
  });

  @override
  ConsumerState<_QuickStatusSheet> createState() => _QuickStatusSheetState();
}

class _QuickStatusSheetState extends ConsumerState<_QuickStatusSheet> {
  late PresenceStatus _selectedStatus;
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentPresence?.status ?? PresenceStatus.idle;
    _messageController.text = widget.currentPresence?.message ?? '';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus() async {
    if (_isSubmitting) return;
    
    setState(() => _isSubmitting = true);

    try {
      await ref.read(presenceNotifierProvider(widget.workspaceId).notifier).updatePresence(
        status: _selectedStatus,
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Center(
            child: Text(
              'Durumunu Güncelle',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Status options
          Text(
            'Durum',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: PresenceStatus.values.map((status) {
              final isSelected = _selectedStatus == status;
              return ChoiceChip(
                avatar: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    shape: BoxShape.circle,
                  ),
                ),
                label: Text(status.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedStatus = status);
                },
                selectedColor: _getStatusColor(status).withOpacity(0.2),
                backgroundColor: colorScheme.surfaceContainerHigh,
                labelStyle: TextStyle(
                  color: isSelected
                      ? _getStatusColor(status)
                      : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Message input
          Text(
            'Mesaj (opsiyonel)',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              hintText: 'Ne üzerinde çalışıyorsun?',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            maxLength: 100,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Quick messages
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _QuickMessageChip(
                label: '☕ Mola',
                onTap: () => _messageController.text = '☕ Mola',
              ),
              _QuickMessageChip(
                label: '🎯 Odaklanıyorum',
                onTap: () => _messageController.text = '🎯 Odaklanıyorum',
              ),
              _QuickMessageChip(
                label: '📞 Toplantıda',
                onTap: () => _messageController.text = '📞 Toplantıda',
              ),
              _QuickMessageChip(
                label: '🍽️ Yemekte',
                onTap: () => _messageController.text = '🍽️ Yemekte',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _updateStatus,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kaydet'),
            ),
          ),
        ],
      ),
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

class _QuickMessageChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickMessageChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}
