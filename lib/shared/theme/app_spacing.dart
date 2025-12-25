import 'package:flutter/material.dart';

/// Design system spacing scale.
/// 
/// Base unit: 4px
/// Scale: 4 / 8 / 12 / 16 / 24 / 32 / 48 / 64
abstract final class AppSpacing {
  // Base unit
  static const double unit = 4.0;

  // Spacing scale
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Common paddings
  static const EdgeInsets paddingXxs = EdgeInsets.all(xxs);
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // Horizontal paddings
  static const EdgeInsets paddingHorizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);

  // Vertical paddings
  static const EdgeInsets paddingVerticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);

  // Screen/Card content padding
  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets dialogPadding = EdgeInsets.all(lg);

  // Common gaps (for use in Column/Row)
  static const SizedBox gapXxs = SizedBox.square(dimension: xxs);
  static const SizedBox gapXs = SizedBox.square(dimension: xs);
  static const SizedBox gapSm = SizedBox.square(dimension: sm);
  static const SizedBox gapMd = SizedBox.square(dimension: md);
  static const SizedBox gapLg = SizedBox.square(dimension: lg);
  static const SizedBox gapXl = SizedBox.square(dimension: xl);

  // Vertical gaps
  static const SizedBox verticalGapXxs = SizedBox(height: xxs);
  static const SizedBox verticalGapXs = SizedBox(height: xs);
  static const SizedBox verticalGapSm = SizedBox(height: sm);
  static const SizedBox verticalGapMd = SizedBox(height: md);
  static const SizedBox verticalGapLg = SizedBox(height: lg);
  static const SizedBox verticalGapXl = SizedBox(height: xl);

  // Horizontal gaps
  static const SizedBox horizontalGapXxs = SizedBox(width: xxs);
  static const SizedBox horizontalGapXs = SizedBox(width: xs);
  static const SizedBox horizontalGapSm = SizedBox(width: sm);
  static const SizedBox horizontalGapMd = SizedBox(width: md);
  static const SizedBox horizontalGapLg = SizedBox(width: lg);
  static const SizedBox horizontalGapXl = SizedBox(width: xl);
}

/// ThemeExtension for accessing spacing via Theme.of(context)
class AppSpacingTheme extends ThemeExtension<AppSpacingTheme> {
  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;

  const AppSpacingTheme({
    this.xxs = AppSpacing.xxs,
    this.xs = AppSpacing.xs,
    this.sm = AppSpacing.sm,
    this.md = AppSpacing.md,
    this.lg = AppSpacing.lg,
    this.xl = AppSpacing.xl,
    this.xxl = AppSpacing.xxl,
    this.xxxl = AppSpacing.xxxl,
  });

  @override
  AppSpacingTheme copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
  }) {
    return AppSpacingTheme(
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
    );
  }

  @override
  AppSpacingTheme lerp(ThemeExtension<AppSpacingTheme>? other, double t) {
    if (other is! AppSpacingTheme) return this;
    return AppSpacingTheme(
      xxs: _lerpDouble(xxs, other.xxs, t),
      xs: _lerpDouble(xs, other.xs, t),
      sm: _lerpDouble(sm, other.sm, t),
      md: _lerpDouble(md, other.md, t),
      lg: _lerpDouble(lg, other.lg, t),
      xl: _lerpDouble(xl, other.xl, t),
      xxl: _lerpDouble(xxl, other.xxl, t),
      xxxl: _lerpDouble(xxxl, other.xxxl, t),
    );
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// Convenience extension on BuildContext for easy spacing access
extension SpacingExtension on BuildContext {
  /// Access spacing theme extension
  AppSpacingTheme get spacing =>
      Theme.of(this).extension<AppSpacingTheme>() ?? const AppSpacingTheme();

  // Quick access to common spacing values
  double get spacingXxs => spacing.xxs;
  double get spacingXs => spacing.xs;
  double get spacingSm => spacing.sm;
  double get spacingMd => spacing.md;
  double get spacingLg => spacing.lg;
  double get spacingXl => spacing.xl;
  double get spacingXxl => spacing.xxl;
}
