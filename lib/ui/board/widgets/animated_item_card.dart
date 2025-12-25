import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../repositories/repositories.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_motion.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_theme.dart';
import 'item_edit_sheet.dart';

/// Animated card widget for displaying an item with micro-interactions
class AnimatedItemCard extends ConsumerStatefulWidget {
  final Item item;
  final String workspaceId;
  final int index;
  final bool animate;

  const AnimatedItemCard({
    super.key,
    required this.item,
    required this.workspaceId,
    this.index = 0,
    this.animate = true,
  });

  @override
  ConsumerState<AnimatedItemCard> createState() => _AnimatedItemCardState();
}

class _AnimatedItemCardState extends ConsumerState<AnimatedItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  ItemState? _previousState;

  @override
  void initState() {
    super.initState();
    _previousState = widget.item.state;
    
    _controller = AnimationController(
      duration: AppMotion.durationMedium,
      vsync: this,
    );

    // Staggered delay based on index
    final delay = Duration(milliseconds: 50 * widget.index.clamp(0, 10));
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: AppMotion.curveDecelerate),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: AppMotion.curveDecelerate),
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
  void didUpdateWidget(covariant AnimatedItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Detect state changes for animation feedback
    if (oldWidget.item.state != widget.item.state) {
      _previousState = oldWidget.item.state;
      
      // Haptic feedback on state change
      if (widget.item.state == ItemState.done) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.selectionClick();
      }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final item = widget.item;

    // State-based styling
    final stateColor = _getStateColor(item.state, colorScheme);
    final isCompleted = item.state == ItemState.done;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: AnimatedContainer(
          duration: AppMotion.durationMedium,
          curve: AppMotion.curveStandard,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: item.state == ItemState.doing 
                  ? stateColor.withOpacity(0.5) 
                  : Colors.transparent,
              width: item.state == ItemState.doing ? 1.5 : 0,
            ),
          ),
          child: Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              onTap: () => _showItemDetail(context),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with state indicator
                    Row(
                      children: [
                        // Animated state indicator
                        _AnimatedStateIndicator(
                          state: item.state,
                          color: stateColor,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        // Title
                        Expanded(
                          child: AnimatedDefaultTextStyle(
                            duration: AppMotion.durationFast,
                            style: theme.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w500,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted
                                  ? colorScheme.onSurface.withOpacity(0.5)
                                  : colorScheme.onSurface,
                            ),
                            child: Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        // Priority indicator
                        if (item.priority == ItemPriority.high)
                          Container(
                            margin: const EdgeInsets.only(left: AppSpacing.xs),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.priority.emoji,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),

                    // Description preview
                    if (item.description != null && item.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        item.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Bottom row with assignee and quick actions
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        // Assignee
                        if (item.isAssigned)
                          _AnimatedAssigneeChip(
                            userId: item.assigneeUserId!,
                            workspaceId: widget.workspaceId,
                          )
                        else
                          Chip(
                            label: Text(
                              'Atanmamış',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            avatar: Icon(
                              Icons.person_outline,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            side: BorderSide.none,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                          ),

                        const Spacer(),

                        // Quick state change buttons with animation
                        _AnimatedQuickStateButtons(
                          item: item,
                          workspaceId: widget.workspaceId,
                          stateColor: stateColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStateColor(ItemState state, ColorScheme colorScheme) {
    switch (state) {
      case ItemState.todo:
        return AppColors.stateTodo;
      case ItemState.doing:
        return AppColors.stateDoing;
      case ItemState.done:
        return AppColors.stateDone;
    }
  }
}

/// Animated state indicator with pulse effect for "doing" state
class _AnimatedStateIndicator extends StatefulWidget {
  final ItemState state;
  final Color color;

  const _AnimatedStateIndicator({
    required this.state,
    required this.color,
  });

  @override
  State<_AnimatedStateIndicator> createState() => _AnimatedStateIndicatorState();
}

class _AnimatedStateIndicatorState extends State<_AnimatedStateIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    if (widget.state == ItemState.doing) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedStateIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == ItemState.doing && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.state != ItemState.doing) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = widget.state == ItemState.doing 
            ? 1.0 + (_pulseController.value * 0.3) 
            : 1.0;
        final opacity = widget.state == ItemState.doing 
            ? 0.6 + (_pulseController.value * 0.4) 
            : 1.0;
        
        return AnimatedContainer(
          duration: AppMotion.durationFast,
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(opacity),
            boxShadow: widget.state == ItemState.doing
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4 * scale),
                      blurRadius: 4 * scale,
                      spreadRadius: 1 * scale,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}

/// Animated assignee chip with crossfade
class _AnimatedAssigneeChip extends ConsumerWidget {
  final String userId;
  final String workspaceId;

  const _AnimatedAssigneeChip({
    required this.userId,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRepo = ref.read(userRepositoryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder(
      future: userRepo.getUser(userId),
      builder: (context, snapshot) {
        final userName = snapshot.data?.displayName ?? '...';
        final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

        return Chip(
          label: AnimatedSwitcher(
            duration: AppMotion.durationFast,
            child: Text(
              userName,
              key: ValueKey(userName),
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          avatar: AnimatedSwitcher(
            duration: AppMotion.durationFast,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: CircleAvatar(
              key: ValueKey(initial),
              radius: 10,
              backgroundColor: colorScheme.primary,
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide.none,
          backgroundColor: colorScheme.secondaryContainer,
        );
      },
    );
  }
}

/// Animated quick state change buttons
class _AnimatedQuickStateButtons extends ConsumerStatefulWidget {
  final Item item;
  final String workspaceId;
  final Color stateColor;

  const _AnimatedQuickStateButtons({
    required this.item,
    required this.workspaceId,
    required this.stateColor,
  });

  @override
  ConsumerState<_AnimatedQuickStateButtons> createState() =>
      _AnimatedQuickStateButtonsState();
}

class _AnimatedQuickStateButtonsState
    extends ConsumerState<_AnimatedQuickStateButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  bool _showCheck = false;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      duration: AppMotion.durationMedium,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    HapticFeedback.lightImpact();
    
    setState(() => _showCheck = true);
    await _checkController.forward();
    
    final notifier = ref.read(itemNotifierProvider(widget.workspaceId).notifier);
    await notifier.markAsDone(
      widget.item.id,
      itemTitle: widget.item.title,
      oldState: widget.item.state,
    );
    
    if (mounted) {
      _checkController.reset();
      setState(() => _showCheck = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(itemNotifierProvider(widget.workspaceId).notifier);
    final colorScheme = Theme.of(context).colorScheme;
    
    // Mevcut kullanıcı ID'si
    final currentUserId = ref.watch(firebaseAuthStateProvider).valueOrNull?.uid;
    
    // Görev atandıysa sadece atanan kişi tamamlayabilir
    final canComplete = widget.item.assigneeUserId == null || 
                        widget.item.assigneeUserId == currentUserId;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Start working
        if (widget.item.state == ItemState.todo)
          IconButton(
            icon: Icon(
              Icons.play_arrow_rounded,
              size: 20,
              color: colorScheme.primary,
            ),
            tooltip: 'Başla',
            onPressed: () {
              HapticFeedback.selectionClick();
              notifier.startWorking(
                widget.item.id,
                itemTitle: widget.item.title,
                oldState: widget.item.state,
              );
            },
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer.withOpacity(0.3),
            ),
          ),

        // Complete with animation (sadece atanan kişi veya atanmamışsa herkes)
        if (widget.item.state == ItemState.doing && canComplete)
          AnimatedBuilder(
            animation: _checkController,
            builder: (context, child) {
              return IconButton(
                icon: AnimatedSwitcher(
                  duration: AppMotion.durationFast,
                  child: _showCheck
                      ? Icon(
                          Icons.check_circle,
                          key: const ValueKey('checked'),
                          size: 20,
                          color: colorScheme.tertiary,
                        )
                      : Icon(
                          Icons.check_rounded,
                          key: const ValueKey('unchecked'),
                          size: 20,
                          color: colorScheme.tertiary,
                        ),
                ),
                tooltip: 'Tamamla',
                onPressed: _handleComplete,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.tertiaryContainer.withOpacity(0.3),
                ),
              );
            },
          ),
      ],
    );
  }
}
