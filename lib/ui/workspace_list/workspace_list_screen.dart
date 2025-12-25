import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';
import '../../shared/theme/app_theme.dart';

/// Main workspace list screen
class WorkspaceListScreen extends ConsumerStatefulWidget {
  const WorkspaceListScreen({super.key});

  @override
  ConsumerState<WorkspaceListScreen> createState() =>
      _WorkspaceListScreenState();
}

class _WorkspaceListScreenState extends ConsumerState<WorkspaceListScreen> {
  @override
  void initState() {
    super.initState();
    // Load workspaces when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workspaceListProvider.notifier).loadWorkspaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workspaceState = ref.watch(workspaceListProvider);
    final currentUser = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace\'lerim'),
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(themeMode.icon),
            tooltip: themeMode.label,
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(themeModeProvider.notifier).cycleThemeMode();
            },
          ),
          // User menu with settings
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'theme':
                  ref.read(themeModeProvider.notifier).cycleThemeMode();
                  break;
                case 'logout':
                  await ref.read(authStateProvider.notifier).signOut();
                  if (mounted) {
                    context.go('/onboarding');
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'user',
                enabled: false,
                child: currentUser.when(
                  data: (user) => Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          (user?.displayName ?? 'K')[0].toUpperCase(),
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Kullanıcı',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              'Giriş yapıldı',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  loading: () => const Text('Yükleniyor...'),
                  error: (_, __) => const Text('Kullanıcı'),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(themeMode.icon),
                    const SizedBox(width: 12),
                    Text('Tema: ${themeMode.label}'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: colorScheme.error),
                    const SizedBox(width: 12),
                    Text(
                      'Çıkış Yap',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(workspaceState),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Join workspace button
          FloatingActionButton.extended(
            heroTag: 'join',
            onPressed: () {
              HapticFeedback.selectionClick();
              context.push('/join');
            },
            icon: const Icon(Icons.group_add),
            label: const Text('Katıl'),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor:
                Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(height: 12),
          // Create workspace button
          FloatingActionButton.extended(
            heroTag: 'create',
            onPressed: () {
              HapticFeedback.selectionClick();
              context.push('/create');
            },
            icon: const Icon(Icons.add),
            label: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(WorkspaceListState state) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Workspace\'ler yükleniyor...');
    }

    if (state.error != null) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () =>
            ref.read(workspaceListProvider.notifier).loadWorkspaces(),
      );
    }

    if (state.workspaces.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.workspaces_outline,
        title: 'Henüz workspace yok',
        subtitle:
            'Yeni bir workspace oluşturun veya davet kodu ile bir workspace\'e katılın.',
        action: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                context.push('/join');
              },
              icon: const Icon(Icons.group_add),
              label: const Text('Katıl'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                context.push('/create');
              },
              icon: const Icon(Icons.add),
              label: const Text('Oluştur'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(workspaceListProvider.notifier).loadWorkspaces();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.workspaces.length + 1, // +1 for header
        itemBuilder: (context, index) {
          // Header with global status toggle
          if (index == 0) {
            return _GlobalStatusToggle(workspaces: state.workspaces);
          }
          
          final workspace = state.workspaces[index - 1];
          return _WorkspaceCard(
            workspace: workspace,
            onTap: () => context.push('/workspace/${workspace.id}'),
          );
        },
      ),
    );
  }
}

/// Global status toggle that updates status across all workspaces
class _GlobalStatusToggle extends ConsumerStatefulWidget {
  final List<Workspace> workspaces;
  
  const _GlobalStatusToggle({required this.workspaces});
  
  @override
  ConsumerState<_GlobalStatusToggle> createState() => _GlobalStatusToggleState();
}

class _GlobalStatusToggleState extends ConsumerState<_GlobalStatusToggle> {
  bool _isUpdating = false;
  Presence? _currentPresence;
  
  @override
  void initState() {
    super.initState();
    // Initial load of presence
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPresence();
    });
  }
  
  void _loadPresence() {
    if (widget.workspaces.isNotEmpty) {
      final notifierState = ref.read(presenceNotifierProvider(widget.workspaces.first.id));
      if (notifierState.currentPresence != null) {
        setState(() => _currentPresence = notifierState.currentPresence);
      }
    }
  }
  
  Future<void> _updateStatusForAllWorkspaces(PresenceStatus status, {String? message}) async {
    if (_isUpdating) return;
    
    setState(() => _isUpdating = true);
    
    try {
      // Update status in all workspaces
      for (final workspace in widget.workspaces) {
        await ref.read(presenceNotifierProvider(workspace.id).notifier).updatePresence(
          status: status,
          message: message,
        );
      }
      
      // Update local state immediately
      if (widget.workspaces.isNotEmpty) {
        final notifierState = ref.read(presenceNotifierProvider(widget.workspaces.first.id));
        setState(() => _currentPresence = notifierState.currentPresence);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Durum güncellendi: ${status.displayName}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }
  
  void _showStatusSheet() {
    final colorScheme = Theme.of(context).colorScheme;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Durumunu Güncelle',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tüm workspace\'lerde durumun güncellenecek',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            
            // Status options
            ...PresenceStatus.values.map((status) => ListTile(
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(status.displayName),
              onTap: () {
                Navigator.pop(context);
                _updateStatusForAllWorkspaces(status);
              },
            )),
            
            const SizedBox(height: 16),
          ],
        ),
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
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Listen for presence changes and update local state
    if (widget.workspaces.isNotEmpty) {
      ref.listen<PresenceState>(
        presenceNotifierProvider(widget.workspaces.first.id),
        (previous, next) {
          if (next.currentPresence != null && next.currentPresence != _currentPresence) {
            setState(() => _currentPresence = next.currentPresence);
          }
        },
      );
      
      // Also watch for stream updates (from Firestore)
      final streamPresence = ref.watch(myPresenceProvider(widget.workspaces.first.id));
      if (_currentPresence == null && streamPresence != null) {
        // Use stream data if local state is not set
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _currentPresence == null) {
            setState(() => _currentPresence = streamPresence);
          }
        });
      }
    }
    
    final firstPresence = _currentPresence;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: _isUpdating ? null : _showStatusSheet,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer.withOpacity(0.5),
                colorScheme.secondaryContainer.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              // Status indicator with animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: firstPresence != null 
                      ? _getStatusColor(firstPresence.status).withOpacity(0.2)
                      : colorScheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _isUpdating
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: firstPresence != null 
                                ? _getStatusColor(firstPresence.status)
                                : colorScheme.outline,
                            shape: BoxShape.circle,
                            boxShadow: firstPresence != null ? [
                              BoxShadow(
                                color: _getStatusColor(firstPresence.status).withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ] : null,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Durumum',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        firstPresence?.status.displayName ?? 'Durum seç',
                        key: ValueKey(firstPresence?.status),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (firstPresence?.hasMessage == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          firstPresence!.message!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Edit icon
              Icon(
                Icons.edit_rounded,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceCard extends ConsumerWidget {
  final dynamic workspace;
  final VoidCallback onTap;

  const _WorkspaceCard({
    required this.workspace,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenceList = ref.watch(workspacePresenceStreamProvider(workspace.id));
    final currentUserId = ref.watch(authServiceProvider).currentUserId;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Workspace avatar
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      workspace.name.isNotEmpty ? workspace.name[0].toUpperCase() : 'W',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workspace.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Oluşturulma: ${_formatDate(workspace.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Icon(Icons.chevron_right, color: colorScheme.outline),
                ],
              ),
              
              // Active members section
              presenceList.when(
                data: (presences) {
                  if (presences.isEmpty) return const SizedBox.shrink();
                  
                  // Filter out current user and sort by status
                  final otherMembers = presences
                      .where((p) => p.userId != currentUserId)
                      .toList();
                  
                  if (otherMembers.isEmpty) return const SizedBox.shrink();
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      
                      // Member presence avatars with animation
                      SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            // Show up to 4 member avatars
                            ...otherMembers.take(4).map((presence) => 
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _AnimatedMemberAvatar(
                                  presence: presence,
                                  colorScheme: colorScheme,
                                ),
                              ),
                            ),
                            
                            // Show count if more than 4
                            if (otherMembers.length > 4)
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHigh,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '+${otherMembers.length - 4}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            
                            const Spacer(),
                            
                            // Active count badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.presenceActive.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${otherMembers.length} aktif',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.presenceActive,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Animated member avatar with presence status
class _AnimatedMemberAvatar extends ConsumerWidget {
  final Presence presence;
  final ColorScheme colorScheme;
  
  const _AnimatedMemberAvatar({
    required this.presence,
    required this.colorScheme,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider(presence.userId));
    
    return userAsync.when(
      data: (user) {
        final name = user?.displayName ?? '?';
        
        return Tooltip(
          message: '${name}: ${presence.status.displayName}${presence.hasMessage ? '\n${presence.message}' : ''}',
          child: Stack(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.surfaceContainerHigh,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _getStatusColor(presence.status),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(presence.status).withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => CircleAvatar(
        radius: 16,
        backgroundColor: colorScheme.surfaceContainerHigh,
        child: const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 1),
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
