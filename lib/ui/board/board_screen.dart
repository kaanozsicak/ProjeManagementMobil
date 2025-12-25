import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../repositories/repositories.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/board_section_widget.dart';
import 'widgets/item_create_sheet.dart';
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
    _initializePresence();
  }

  Future<void> _initializePresence() async {
    // Ensure user has a presence record when entering the board
    // Only create if doesn't exist - don't override existing status
    final presenceNotifier = ref.read(presenceNotifierProvider(widget.workspaceId).notifier);
    await presenceNotifier.ensurePresenceExists();
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
    showItemCreateSheet(
      context,
      workspaceId: widget.workspaceId,
      defaultType: defaultType,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Geri',
          onPressed: () {
            HapticFeedback.selectionClick();
            context.go('/workspace/${widget.workspaceId}');
          },
        ),
        title: Text(_workspace?.name ?? 'Yükleniyor...'),
        actions: [
          // Completed items button with badge
          completedAsync.when(
            data: (completed) => Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  tooltip: 'Tamamlananlar',
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _showCompletedItems();
                  },
                ),
                if (completed.isNotEmpty)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 1.5,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        completed.length > 99 ? '99+' : '${completed.length}',
                        style: TextStyle(
                          color: colorScheme.onTertiary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
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
              HapticFeedback.selectionClick();
              ref.invalidate(boardItemsStreamProvider(widget.workspaceId));
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: itemsAsync.when(
          data: (items) {
            if (items.isEmpty && sections.every((s) => s.isEmpty)) {
              return _buildEmptyState();
            }
            return _buildBoard(sections);
          },
          loading: () => const SkeletonBoard(key: ValueKey('skeleton')),
          error: (error, _) => AppErrorWidget(
            key: const ValueKey('error'),
            message: 'Pano yüklenemedi: $error',
            onRetry: () {
              ref.invalidate(boardItemsStreamProvider(widget.workspaceId));
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.selectionClick();
          _showCreateItemDialog();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Görev'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // My presence status widget - always show
        PresenceStatusWidget(workspaceId: widget.workspaceId),
        const SizedBox(height: AppSpacing.md),

        // Active users section - always show
        ActiveUsersSection(workspaceId: widget.workspaceId),

        // Empty state message
        const SizedBox(height: AppSpacing.xl),
        EmptyStateWidget(
          icon: Icons.dashboard_outlined,
          title: 'Pano Boş',
          subtitle: 'Henüz hiç görev eklenmemiş.\nİlk görevi ekleyerek başlayın!',
          action: FilledButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              _showCreateItemDialog();
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('İlk Görevi Ekle'),
          ),
        ),
        // Extra padding for FAB
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildBoard(List<BoardSection> sections) {
    final completedAsync =
        ref.watch(completedItemsStreamProvider(widget.workspaceId));
    final colorScheme = Theme.of(context).colorScheme;
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(boardItemsStreamProvider(widget.workspaceId));
        ref.invalidate(workspacePresenceStreamProvider(widget.workspaceId));
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // My presence status widget
          PresenceStatusWidget(workspaceId: widget.workspaceId),
          const SizedBox(height: AppSpacing.md),

          // Active users section (who's working on what)
          ActiveUsersSection(workspaceId: widget.workspaceId),

          // Board sections with stagger animation
          ...sections.asMap().entries.map((entry) {
            final index = entry.key;
            final section = entry.value;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: BoardSectionWidget(
                section: section,
                workspaceId: widget.workspaceId,
                onAddItem: () => _showCreateItemDialog(section.type),
              ),
            );
          }),
          
          // Completed items teaser section
          const SizedBox(height: AppSpacing.sm),
          completedAsync.when(
            data: (completed) {
              if (completed.isEmpty) return const SizedBox.shrink();
              
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _showCompletedItems();
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.08),
                        colorScheme.tertiary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: const Text('✅', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tamamlanan Görevler',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${completed.length} görev tamamlandı 🎉',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Extra padding for FAB
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildActivityButton() {
    final unreadCount = ref.watch(unreadActivityCountProvider(widget.workspaceId));
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.history),
          tooltip: 'Son Hareketler',
          onPressed: () {
            HapticFeedback.selectionClick();
            context.push('/workspace/${widget.workspaceId}/activities');
          },
        ),
        if (unreadCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: colorScheme.error,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.surface,
                  width: 1.5,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: TextStyle(
                  color: colorScheme.onError,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
