import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../repositories/repositories.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/board_section_widget.dart';
import 'widgets/item_create_dialog.dart';
import 'widgets/completed_items_sheet.dart';
import 'widgets/active_users_section.dart';
import 'widgets/presence_status_widget.dart';

/// Main board screen - Keep-style layout with sections
class BoardScreen extends ConsumerStatefulWidget {
  final String workspaceId;

  const BoardScreen({
    super.key,
    required this.workspaceId,
  });

  @override
  ConsumerState<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends ConsumerState<BoardScreen> {
  Workspace? _workspace;
  bool _isLoadingWorkspace = true;

  @override
  void initState() {
    super.initState();
    _loadWorkspace();
  }

  Future<void> _loadWorkspace() async {
    final workspaceRepo = ref.read(workspaceRepositoryProvider);
    final workspace = await workspaceRepo.getWorkspace(widget.workspaceId);
    if (mounted) {
      setState(() {
        _workspace = workspace;
        _isLoadingWorkspace = false;
      });
    }
  }

  void _showCreateItemDialog([ItemType? defaultType]) {
    showDialog(
      context: context,
      builder: (context) => ItemCreateDialog(
        workspaceId: widget.workspaceId,
        defaultType: defaultType,
      ),
    );
  }

  void _showCompletedItems() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => CompletedItemsSheet(
        workspaceId: widget.workspaceId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(boardItemsStreamProvider(widget.workspaceId));
    final sections = ref.watch(boardSectionsProvider(widget.workspaceId));
    final completedAsync =
        ref.watch(completedItemsStreamProvider(widget.workspaceId));

    return Scaffold(
      appBar: AppBar(
        title: Text(_workspace?.name ?? 'Yükleniyor...'),
        actions: [
          // Completed items button with badge
          completedAsync.when(
            data: (completed) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  tooltip: 'Tamamlananlar',
                  onPressed: _showCompletedItems,
                ),
                if (completed.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${completed.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            loading: () => const IconButton(
              icon: Icon(Icons.check_circle_outline),
              onPressed: null,
            ),
            error: (_, __) => const IconButton(
              icon: Icon(Icons.check_circle_outline),
              onPressed: null,
            ),
          ),
          // Activity log button with badge
          _buildActivityButton(),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: () {
              ref.invalidate(boardItemsStreamProvider(widget.workspaceId));
            },
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty && sections.every((s) => s.isEmpty)) {
            return _buildEmptyState();
          }
          return _buildBoard(sections);
        },
        loading: () => const LoadingWidget(message: 'Board yükleniyor...'),
        error: (error, _) => AppErrorWidget(
          message: 'Board yüklenemedi: $error',
          onRetry: () {
            ref.invalidate(boardItemsStreamProvider(widget.workspaceId));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateItemDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Item'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // My presence status widget - always show
        PresenceStatusWidget(workspaceId: widget.workspaceId),
        const SizedBox(height: 16),

        // Active users section - always show
        ActiveUsersSection(workspaceId: widget.workspaceId),

        // Empty state message
        const SizedBox(height: 32),
        EmptyStateWidget(
          icon: Icons.dashboard_outlined,
          title: 'Board boş',
          subtitle: 'Henüz hiç item eklenmemiş.\nİlk item\'ı ekleyerek başlayın!',
          action: ElevatedButton.icon(
            onPressed: () => _showCreateItemDialog(),
            icon: const Icon(Icons.add),
            label: const Text('İlk Item\'ı Ekle'),
          ),
        ),
      ],
    );
  }

  Widget _buildBoard(List<BoardSection> sections) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(boardItemsStreamProvider(widget.workspaceId));
        ref.invalidate(workspacePresenceStreamProvider(widget.workspaceId));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // My presence status widget
          PresenceStatusWidget(workspaceId: widget.workspaceId),
          const SizedBox(height: 16),

          // Active users section (who's working on what)
          ActiveUsersSection(workspaceId: widget.workspaceId),

          // Board sections
          ...sections.map((section) => BoardSectionWidget(
                section: section,
                workspaceId: widget.workspaceId,
                onAddItem: () => _showCreateItemDialog(section.type),
              )),
        ],
      ),
    );
  }

  Widget _buildActivityButton() {
    final unreadCount = ref.watch(unreadActivityCountProvider(widget.workspaceId));

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.history),
          tooltip: 'Son Hareketler',
          onPressed: () {
            context.push('/workspace/${widget.workspaceId}/activities');
          },
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
