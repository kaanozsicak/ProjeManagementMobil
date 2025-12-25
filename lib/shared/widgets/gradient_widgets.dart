import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Modern, colorful gradient widgets for the app.
/// 
/// Provides reusable gradient backgrounds, buttons, and decorations
/// for a vibrant, premium feel.

// ============================================
// Gradient Background Containers
// ============================================

/// Container with gradient background
class GradientContainer extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final AlignmentGeometry? alignment;

  const GradientContainer({
    super.key,
    required this.child,
    this.gradient,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.boxShadow,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      alignment: alignment,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.gradientPrimary,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

/// Card with subtle gradient overlay
class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final double? opacity;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool elevated;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.opacity = 0.05,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark 
                ? colorScheme.surfaceContainerLow 
                : colorScheme.surfaceBright,
            gradient: LinearGradient(
              colors: [
                (gradient?.colors.first ?? colorScheme.primary).withOpacity(opacity!),
                Colors.transparent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            border: isDark 
                ? Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.1),
                  )
                : null,
            boxShadow: elevated
                ? [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.2)
                          : colorScheme.shadow.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

// ============================================
// Gradient Buttons
// ============================================

/// Button with gradient background
class GradientButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.child,
    this.onPressed,
    this.gradient,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final grad = widget.gradient ?? AppColors.gradientPrimary;
    
    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        width: widget.width,
        height: widget.height ?? 48,
        decoration: BoxDecoration(
          gradient: widget.onPressed != null ? grad : null,
          color: widget.onPressed == null 
              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.12)
              : null,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          boxShadow: widget.onPressed != null
              ? [
                  BoxShadow(
                    color: grad.colors.first.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Padding(
              padding: widget.padding ?? 
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                        child: IconTheme(
                          data: const IconThemeData(
                            color: Colors.white,
                            size: 20,
                          ),
                          child: widget.child,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small pill button with gradient
class GradientPill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final bool small;

  const GradientPill({
    super.key,
    required this.text,
    this.icon,
    this.onTap,
    this.gradient,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(100),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: small ? 10 : 14,
            vertical: small ? 4 : 6,
          ),
          decoration: BoxDecoration(
            gradient: gradient ?? AppColors.gradientPrimary,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: small ? 14 : 16,
                  color: Colors.white,
                ),
                SizedBox(width: small ? 4 : 6),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: small ? 11 : 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// Gradient Text
// ============================================

/// Text with gradient fill
class GradientText extends StatelessWidget {
  final String text;
  final Gradient? gradient;
  final TextStyle? style;
  final TextAlign? textAlign;

  const GradientText({
    super.key,
    required this.text,
    this.gradient,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => (gradient ?? AppColors.gradientPrimary)
          .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: style ?? const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textAlign: textAlign,
      ),
    );
  }
}

// ============================================
// Gradient Icon
// ============================================

/// Icon with gradient fill
class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Gradient? gradient;

  const GradientIcon({
    super.key,
    required this.icon,
    this.size = 24,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => (gradient ?? AppColors.gradientPrimary)
          .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Icon(icon, size: size),
    );
  }
}

// ============================================
// Gradient Border Container
// ============================================

/// Container with gradient border
class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const GradientBorderContainer({
    super.key,
    required this.child,
    this.gradient,
    this.borderWidth = 2,
    this.borderRadius = 12,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? 
              (isDark 
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.surfaceBright),
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        ),
        child: child,
      ),
    );
  }
}

// ============================================
// Colored Status Badge
// ============================================

/// Status badge with semantic color
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool outlined;
  final bool small;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.outlined = false,
    this.small = false,
    this.icon,
  });

  /// Factory for todo state
  factory StatusBadge.todo({bool small = false}) => StatusBadge(
    text: 'Yapılacak',
    color: AppColors.stateTodo,
    small: small,
    icon: Icons.radio_button_unchecked_rounded,
  );

  /// Factory for doing state
  factory StatusBadge.doing({bool small = false}) => StatusBadge(
    text: 'Yapılıyor',
    color: AppColors.stateDoing,
    small: small,
    icon: Icons.play_circle_outline_rounded,
  );

  /// Factory for done state
  factory StatusBadge.done({bool small = false}) => StatusBadge(
    text: 'Tamamlandı',
    color: AppColors.stateDone,
    small: small,
    icon: Icons.check_circle_outline_rounded,
  );

  /// Factory for priority
  factory StatusBadge.priority(String priority, {bool small = false}) {
    switch (priority) {
      case 'high':
        return StatusBadge(
          text: 'Yüksek',
          color: AppColors.priorityHigh,
          small: small,
          icon: Icons.keyboard_double_arrow_up_rounded,
        );
      case 'medium':
        return StatusBadge(
          text: 'Orta',
          color: AppColors.priorityMedium,
          small: small,
          icon: Icons.remove_rounded,
        );
      default:
        return StatusBadge(
          text: 'Düşük',
          color: AppColors.priorityLow,
          small: small,
          icon: Icons.keyboard_double_arrow_down_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withOpacity(isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(100),
        border: outlined 
            ? Border.all(color: color.withOpacity(0.5), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: small ? 12 : 14,
              color: color,
            ),
            SizedBox(width: small ? 3 : 5),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: small ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Type Badge
// ============================================

/// Badge for item type with emoji
class TypeBadge extends StatelessWidget {
  final String type;
  final bool showLabel;
  final bool small;

  const TypeBadge({
    super.key,
    required this.type,
    this.showLabel = true,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final (Color color, String emoji, String label) = switch (type) {
      'activeTask' => (AppColors.typeActive, '🎯', 'Active'),
      'bug' => (AppColors.typeBug, '🐛', 'Bug'),
      'logic' => (AppColors.typeLogic, '⚙️', 'Logic'),
      'idea' => (AppColors.typeIdea, '💡', 'Fikir'),
      _ => (AppColors.typeActive, '📋', 'Görev'),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: small ? 10 : 12),
          ),
          if (showLabel) ...[
            SizedBox(width: small ? 3 : 5),
            Text(
              label,
              style: TextStyle(
                fontSize: small ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================
// Glow Effect Container
// ============================================

/// Container with glow effect
class GlowContainer extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final double blurRadius;
  final double spreadRadius;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GlowContainer({
    super.key,
    required this.child,
    this.glowColor,
    this.blurRadius = 20,
    this.spreadRadius = 0,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final color = glowColor ?? Theme.of(context).colorScheme.primary;
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
      child: child,
    );
  }
}

// ============================================
// Animated Color Dot
// ============================================

/// Animated color dot (for presence, status)
class AnimatedColorDot extends StatefulWidget {
  final Color color;
  final double size;
  final bool animate;

  const AnimatedColorDot({
    super.key,
    required this.color,
    this.size = 10,
    this.animate = false,
  });

  @override
  State<AnimatedColorDot> createState() => _AnimatedColorDotState();
}

class _AnimatedColorDotState extends State<AnimatedColorDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedColorDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: widget.animate
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(_animation.value * 0.5),
                      blurRadius: widget.size * 0.8,
                      spreadRadius: widget.size * 0.2,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}
