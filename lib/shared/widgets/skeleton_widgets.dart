import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_motion.dart';

/// Skeleton loading widgets for premium loading experience
/// 
/// These provide shimmer-like loading placeholders without external dependencies.

/// Base skeleton container with animated shimmer effect
class SkeletonContainer extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsets? margin;
  
  const SkeletonContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.margin,
  });

  @override
  State<SkeletonContainer> createState() => _SkeletonContainerState();
}

class _SkeletonContainerState extends State<SkeletonContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final baseColor = isDark 
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surfaceContainerHighest.withOpacity(0.8);
    final shimmerColor = isDark
        ? theme.colorScheme.surface.withOpacity(0.3)
        : Colors.white.withOpacity(0.5);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                shimmerColor,
                baseColor,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton for a single item card - matches AnimatedItemCard layout
class SkeletonItemCard extends StatelessWidget {
  const SkeletonItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with state indicator
            Row(
              children: [
                // State indicator dot
                SkeletonContainer(
                  width: 8,
                  height: 8,
                  borderRadius: 4,
                ),
                const SizedBox(width: AppSpacing.xs),
                // Title
                const Expanded(
                  child: SkeletonContainer(
                    height: 18,
                    borderRadius: 4,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Priority indicator
                SkeletonContainer(
                  width: 8,
                  height: 8,
                  borderRadius: 4,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // Description (optional)
            const SkeletonContainer(
              height: 14,
              borderRadius: 4,
            ),
            const SizedBox(height: AppSpacing.sm),
            // Bottom row with assignee and quick actions
            Row(
              children: [
                // Assignee chip
                SkeletonContainer(
                  width: 80,
                  height: 28,
                  borderRadius: 14,
                ),
                const Spacer(),
                // Quick action buttons
                SkeletonContainer(
                  width: 72,
                  height: 28,
                  borderRadius: 6,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for a board section - matches BoardSectionWidget layout
class SkeletonBoardSection extends StatelessWidget {
  final int itemCount;
  
  const SkeletonBoardSection({
    super.key, 
    this.itemCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header - matches BoardSectionWidget header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, 
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                // Emoji placeholder
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SkeletonContainer(
                    width: 18,
                    height: 18,
                    borderRadius: 4,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Title
                Expanded(
                  child: SkeletonContainer(
                    height: 18,
                    borderRadius: 4,
                  ),
                ),
                // Count badge
                SkeletonContainer(
                  width: 28,
                  height: 22,
                  borderRadius: 11,
                ),
                const SizedBox(width: AppSpacing.xs),
                // Expand icon
                SkeletonContainer(
                  width: 20,
                  height: 20,
                  borderRadius: 4,
                ),
                const SizedBox(width: AppSpacing.xs),
                // Add button
                SkeletonContainer(
                  width: 32,
                  height: 32,
                  borderRadius: 8,
                ),
              ],
            ),
          ),
          // Items
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Column(
              children: List.generate(
                itemCount,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index < itemCount - 1 ? AppSpacing.xxs : 0,
                  ),
                  child: const SkeletonItemCard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full board skeleton with multiple sections
class SkeletonBoard extends StatelessWidget {
  const SkeletonBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('skeleton-board'),
      padding: const EdgeInsets.all(AppSpacing.md),
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        // Presence status skeleton - matches PresenceStatusWidget
        _SkeletonPresenceStatus(),
        SizedBox(height: AppSpacing.md),
        // Active users section skeleton - matches ActiveUsersSection
        _SkeletonActiveUsers(),
        // Board sections - 4 sections like real board
        SkeletonBoardSection(itemCount: 2),
        SkeletonBoardSection(itemCount: 2),
        SkeletonBoardSection(itemCount: 1),
        SkeletonBoardSection(itemCount: 1),
      ],
    );
  }
}

/// Skeleton matching PresenceStatusWidget
class _SkeletonPresenceStatus extends StatelessWidget {
  const _SkeletonPresenceStatus();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Status indicator dot
            SkeletonContainer(
              width: 12,
              height: 12,
              borderRadius: 6,
            ),
            const SizedBox(width: 12),
            // Status text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonContainer(
                    width: 120,
                    height: 16,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 4),
                  SkeletonContainer(
                    width: 180,
                    height: 12,
                    borderRadius: 4,
                  ),
                ],
              ),
            ),
            // Edit icon placeholder
            SkeletonContainer(
              width: 18,
              height: 18,
              borderRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton matching ActiveUsersSection
class _SkeletonActiveUsers extends StatelessWidget {
  const _SkeletonActiveUsers();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header matching ActiveUsersSection
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                SkeletonContainer(
                  width: 24,
                  height: 24,
                  borderRadius: 4,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: SkeletonContainer(
                    height: 18,
                    borderRadius: 4,
                  ),
                ),
                SkeletonContainer(
                  width: 24,
                  height: 20,
                  borderRadius: 10,
                ),
              ],
            ),
          ),
          // User cards
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: List.generate(
                2,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index < 1 ? 8 : 0,
                  ),
                  child: const _SkeletonUserCard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for a user card in ActiveUsersSection
class _SkeletonUserCard extends StatelessWidget {
  const _SkeletonUserCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            SkeletonContainer(
              width: 40,
              height: 40,
              borderRadius: 20,
            ),
            const SizedBox(width: 12),
            // Name and status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonContainer(
                    width: 100,
                    height: 14,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 4),
                  SkeletonContainer(
                    width: 150,
                    height: 12,
                    borderRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for completed items list
class SkeletonCompletedList extends StatelessWidget {
  const SkeletonCompletedList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Date header
        const SkeletonContainer(
          width: 80,
          height: 14,
          borderRadius: 4,
          margin: EdgeInsets.only(bottom: AppSpacing.sm),
        ),
        ...List.generate(
          4,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.xs),
            child: SkeletonItemCard(),
          ),
        ),
      ],
    );
  }
}
