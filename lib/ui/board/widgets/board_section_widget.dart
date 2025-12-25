import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_motion.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_theme.dart';
import 'animated_item_card.dart';
import 'item_edit_sheet.dart';

/// A board section widget with modern animations (like Keep sections)
class BoardSectionWidget extends ConsumerStatefulWidget {
  final BoardSection section;
  final String workspaceId;
  final VoidCallback onAddItem;
  final bool animate;

  const BoardSectionWidget({
    super.key,
    required this.section,
    required this.workspaceId,
    required this.onAddItem,
    this.animate = true,
  });

  @override
  ConsumerState<BoardSectionWidget> createState() => _BoardSectionWidgetState();
}

class _BoardSectionWidgetState extends ConsumerState<BoardSectionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppMotion.durationMedium,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotion.curveDecelerate,
      ),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getSectionColor(ItemType type) {
    switch (type) {
      case ItemType.activeTask:
        return AppColors.typeActive;
      case ItemType.bug:
        return AppColors.typeBug;
      case ItemType.logic:
        return AppColors.typeLogic;
      case ItemType.idea:
        return AppColors.typeIdea;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isIdeaSection = widget.section.type == ItemType.idea;
    final sectionColor = _getSectionColor(widget.section.type);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header with expand/collapse
            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isExpanded = !_isExpanded);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      sectionColor.withOpacity(0.15),
                      sectionColor.withOpacity(0.05),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    // Emoji with background
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: sectionColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                      ),
                      child: Text(
                        widget.section.emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Title
                    Expanded(
                      child: Text(
                        widget.section.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    // Item count badge
                    AnimatedContainer(
                      duration: AppMotion.durationFast,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: sectionColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        '${widget.section.count}',
                        style: TextStyle(
                          color: sectionColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    // Expand/collapse indicator
                    AnimatedRotation(
                      duration: AppMotion.durationFast,
                      turns: _isExpanded ? 0 : -0.25,
                      child: Icon(
                        Icons.expand_more,
                        color: colorScheme.outline,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    // Add button
                    IconButton.filled(
                      icon: const Icon(Icons.add_rounded, size: 18),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        widget.onAddItem();
                      },
                      tooltip: 'Ekle',
                      style: IconButton.styleFrom(
                        backgroundColor: sectionColor.withOpacity(0.2),
                        foregroundColor: sectionColor,
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Idea section special info banner
            if (isIdeaSection && widget.section.items.isNotEmpty && _isExpanded)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                color: Colors.amber.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 14,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Fikirleri görevleştirmek için üzerine tıklayın',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.amber.shade800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Animated size for expand/collapse
            AnimatedSize(
              duration: AppMotion.durationMedium,
              curve: AppMotion.curveStandard,
              alignment: Alignment.topCenter,
              child: _isExpanded
                  ? _buildItemsList(theme, colorScheme, isIdeaSection, sectionColor)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isIdeaSection,
    Color sectionColor,
  ) {
    if (widget.section.isEmpty) {
      return _EmptyState(
        isIdeaSection: isIdeaSection,
        sectionColor: sectionColor,
        onAdd: widget.onAddItem,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.sm),
      itemCount: widget.section.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        final item = widget.section.items[index];
        return isIdeaSection
            ? _IdeaCard(
                item: item,
                workspaceId: widget.workspaceId,
                index: index,
                animate: widget.animate,
              )
            : AnimatedItemCard(
                item: item,
                workspaceId: widget.workspaceId,
                index: index,
                animate: widget.animate,
              );
      },
    );
  }
}

/// Empty state widget with animation
class _EmptyState extends StatelessWidget {
  final bool isIdeaSection;
  final Color sectionColor;
  final VoidCallback onAdd;

  const _EmptyState({
    required this.isIdeaSection,
    required this.sectionColor,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: sectionColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIdeaSection ? Icons.lightbulb_outline : Icons.inbox_outlined,
              size: 32,
              color: sectionColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isIdeaSection
                ? 'Henüz fikir yok'
                : 'Bu bölümde henüz görev yok',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              onAdd();
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(isIdeaSection ? 'Fikir Ekle' : 'Ekle'),
            style: TextButton.styleFrom(
              foregroundColor: sectionColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Special card for ideas with quick convert action and animations
class _IdeaCard extends ConsumerStatefulWidget {
  final Item item;
  final String workspaceId;
  final int index;
  final bool animate;

  const _IdeaCard({
    required this.item,
    required this.workspaceId,
    this.index = 0,
    this.animate = true,
  });

  @override
  ConsumerState<_IdeaCard> createState() => _IdeaCardState();
}

class _IdeaCardState extends ConsumerState<_IdeaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppMotion.durationMedium,
      vsync: this,
    );

    final delay = Duration(milliseconds: 50 * widget.index.clamp(0, 10));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotion.curveDecelerate,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotion.curveDecelerate,
      ),
    );

    if (widget.animate) {
      Future.delayed(delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showItemDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ItemEditSheet(
        item: widget.item,
        workspaceId: widget.workspaceId,
      ),
    );
  }

  Future<void> _convertTo(BuildContext context, ItemType newType) async {
    HapticFeedback.lightImpact();
    final notifier =
        ref.read(itemNotifierProvider(widget.workspaceId).notifier);

    await notifier.convertType(
      widget.item.id,
      newType,
      itemTitle: widget.item.title,
      oldType: widget.item.type,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${newType.emoji} "${widget.item.title}" → ${newType.displayName}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          color: Colors.amber.withOpacity(0.1),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            onTap: () => _showItemDetail(context),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('💡', style: TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          widget.item.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Description preview
                  if (widget.item.description != null &&
                      widget.item.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      widget.item.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Quick convert buttons
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        'Görevleştir:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _QuickConvertChip(
                        emoji: '🎯',
                        label: 'Görev',
                        color: colorScheme.primary,
                        onTap: () => _convertTo(context, ItemType.activeTask),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      _QuickConvertChip(
                        emoji: '🐛',
                        label: 'Bug',
                        color: colorScheme.error,
                        onTap: () => _convertTo(context, ItemType.bug),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      _QuickConvertChip(
                        emoji: '⚙️',
                        label: 'Logic',
                        color: colorScheme.tertiary,
                        onTap: () => _convertTo(context, ItemType.logic),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small chip for quick conversion with hover effect
class _QuickConvertChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickConvertChip({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 10)),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
