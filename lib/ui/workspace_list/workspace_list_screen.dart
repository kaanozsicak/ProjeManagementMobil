import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../shared/widgets/widgets.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace\'lerim'),
        actions: [
          // User info
          currentUser.when(
            data: (user) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Chip(
                avatar: const Icon(Icons.person, size: 18),
                label: Text(user?.displayName ?? 'Kullanıcı'),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Menu
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(authStateProvider.notifier).signOut();
                if (mounted) {
                  context.go('/onboarding');
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Çıkış Yap'),
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
            onPressed: () => context.push('/join'),
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
            onPressed: () => context.push('/create'),
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
              onPressed: () => context.push('/join'),
              icon: const Icon(Icons.group_add),
              label: const Text('Katıl'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => context.push('/create'),
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
        itemCount: state.workspaces.length,
        itemBuilder: (context, index) {
          final workspace = state.workspaces[index];
          return _WorkspaceCard(
            workspace: workspace,
            onTap: () => context.push('/workspace/${workspace.id}'),
          );
        },
      ),
    );
  }
}

class _WorkspaceCard extends StatelessWidget {
  final dynamic workspace;
  final VoidCallback onTap;

  const _WorkspaceCard({
    required this.workspace,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            workspace.name.isNotEmpty ? workspace.name[0].toUpperCase() : 'W',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          workspace.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          'Oluşturulma: ${_formatDate(workspace.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
