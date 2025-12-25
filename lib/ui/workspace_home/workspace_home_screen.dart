import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../repositories/repositories.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';

/// Placeholder home screen for a workspace (Phase 2: Board)
class WorkspaceHomeScreen extends ConsumerStatefulWidget {
  final String workspaceId;

  const WorkspaceHomeScreen({
    super.key,
    required this.workspaceId,
  });

  @override
  ConsumerState<WorkspaceHomeScreen> createState() =>
      _WorkspaceHomeScreenState();
}

class _WorkspaceHomeScreenState extends ConsumerState<WorkspaceHomeScreen> {
  Workspace? _workspace;
  List<Membership>? _members;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWorkspace();
  }

  Future<void> _loadWorkspace() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final workspaceRepo = ref.read(workspaceRepositoryProvider);
      final workspace = await workspaceRepo.getWorkspace(widget.workspaceId);
      final members = await workspaceRepo.getWorkspaceMembers(widget.workspaceId);

      setState(() {
        _workspace = workspace;
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showInviteDialog() async {
    final workspaceRepo = ref.read(workspaceRepositoryProvider);
    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUserId;

    if (userId == null) return;

    // Create new invite
    final invite = await workspaceRepo.createInvite(
      workspaceId: widget.workspaceId,
      createdBy: userId,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Davet Kodu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bu kodu paylaşarak başkalarını davet edebilirsiniz:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      invite.inviteCode,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: invite.inviteCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kopyalandı!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Geçerlilik: 7 gün',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Yükleniyor...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _workspace == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error ?? 'Workspace bulunamadı'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/workspaces'),
                child: const Text('Geri Dön'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_workspace!.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/workspaces'),
        ),
        actions: [
          // Presence status indicator
          PresenceIndicatorWidget(
            workspaceId: widget.workspaceId,
            showLabel: true,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Davet Et',
            onPressed: _showInviteDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase 2 placeholder banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.dashboard_customize,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '📋 Takip Panosu',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Active / Bug / Logic / Completed / Fikir Kutusu\n'
                    'bölümleriyle görevlerinizi takip edin.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/workspace/${widget.workspaceId}/board'),
                    icon: const Icon(Icons.dashboard),
                    label: const Text('Panoyu Aç'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Workspace info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workspace Bilgileri',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Divider(),
                    _InfoRow(
                      label: 'ID',
                      value: _workspace!.id.substring(0, 8) + '...',
                    ),
                    _InfoRow(
                      label: 'Oluşturulma',
                      value: _formatDate(_workspace!.createdAt),
                    ),
                    _InfoRow(
                      label: 'Üye Sayısı',
                      value: '${_members?.length ?? 0}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Members list
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Üyeler',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadWorkspace,
                        ),
                      ],
                    ),
                    const Divider(),
                    if (_members != null && _members!.isNotEmpty)
                      ..._members!.map(
                        (member) => _MemberTile(
                          member: member,
                          workspaceId: widget.workspaceId,
                          isCurrentUser:
                              member.userId ==
                              ref.read(authServiceProvider).currentUserId,
                        ),
                      )
                    else
                      const Text('Üye bulunamadı'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends ConsumerWidget {
  final Membership member;
  final String workspaceId;
  final bool isCurrentUser;

  const _MemberTile({
    required this.member,
    required this.workspaceId,
    required this.isCurrentUser,
  });

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider(member.userId));
    
    // For current user, watch notifier directly for immediate updates
    // For other users, watch stream
    Presence? presence;
    if (isCurrentUser) {
      final notifierState = ref.watch(presenceNotifierProvider(workspaceId));
      presence = notifierState.currentPresence;
      // Fallback to stream if notifier hasn't loaded
      presence ??= ref.watch(userPresenceProvider((
        workspaceId: workspaceId,
        userId: member.userId,
      )));
    } else {
      presence = ref.watch(userPresenceProvider((
        workspaceId: workspaceId,
        userId: member.userId,
      )));
    }

    return userAsync.when(
      data: (user) {
        final displayName = user?.displayName ?? 'Bilinmeyen Kullanıcı';
        final colorScheme = Theme.of(context).colorScheme;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Stack(
            children: [
              CircleAvatar(
                child: Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : '?'),
              ),
              // Presence indicator
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: presence != null
                        ? _getStatusColor(presence.status)
                        : colorScheme.outline,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Row(
            children: [
              Text(displayName),
              if (isCurrentUser)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    '(Sen)',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            presence != null
                ? '${presence.status.displayName}${presence.hasMessage ? " - ${presence.message}" : ""}'
                : member.role.value,
          ),
          trailing: member.isOwner
              ? const Chip(
                  label: Text('Owner'),
                  visualDensity: VisualDensity.compact,
                )
              : null,
        );
      },
      loading: () => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        title: const Text('Yükleniyor...'),
        subtitle: Text(member.role.value),
      ),
      error: (_, __) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(child: Text('?')),
        title: const Text('Kullanıcı bulunamadı'),
        subtitle: Text(member.role.value),
      ),
    );
  }
}
