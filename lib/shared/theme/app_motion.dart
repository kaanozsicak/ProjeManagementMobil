import 'package:flutter/material.dart';

/// Design system motion/animation constants.
/// 
/// Provides consistent animation durations and curves
/// following Material Design 3 motion guidelines.
abstract final class AppMotion {
  // ============================================
  // Durations
  // ============================================
  
  /// Extra short duration for micro-interactions (50ms)
  static const Duration durationXs = Duration(milliseconds: 50);
  
  /// Short duration for simple state changes (100ms)
  static const Duration durationSm = Duration(milliseconds: 100);
  
  /// Fast duration for most transitions (200ms)
  static const Duration durationFast = Duration(milliseconds: 200);
  
  /// Medium duration for complex transitions (300ms)
  static const Duration durationMedium = Duration(milliseconds: 300);
  
  /// Slow duration for emphasis transitions (400ms)
  static const Duration durationSlow = Duration(milliseconds: 400);
  
  /// Extra slow for page transitions (500ms)
  static const Duration durationXl = Duration(milliseconds: 500);

  // ============================================
  // Curves - Material Design 3 Easing
  // ============================================
  
  /// Standard easing for most animations
  static const Curve curveStandard = Curves.easeOutCubic;
  
  /// Emphasized easing for important transitions
  static const Curve curveEmphasized = Curves.easeInOutCubic;
  
  /// Decelerate for entering elements
  static const Curve curveDecelerate = Curves.easeOutQuart;
  
  /// Accelerate for exiting elements
  static const Curve curveAccelerate = Curves.easeInQuart;
  
  /// Linear for continuous animations
  static const Curve curveLinear = Curves.linear;
  
  /// Bounce for playful interactions
  static const Curve curveBounce = Curves.elasticOut;
  
  /// Spring-like curve for natural feel
  static const Curve curveSpring = Curves.easeOutBack;

  // ============================================
  // Page Transitions
  // ============================================
  
  /// Duration for page/route transitions
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  
  /// Curve for page forward transition
  static const Curve pageTransitionCurve = Curves.easeOutCubic;
  
  /// Curve for page reverse transition
  static const Curve pageTransitionReverseCurve = Curves.easeInCubic;

  // ============================================
  // Common Animation Presets
  // ============================================
  
  /// Fade in animation preset
  static const Duration fadeInDuration = durationFast;
  static const Curve fadeInCurve = curveDecelerate;
  
  /// Fade out animation preset
  static const Duration fadeOutDuration = durationSm;
  static const Curve fadeOutCurve = curveAccelerate;
  
  /// Scale animation preset
  static const Duration scaleDuration = durationMedium;
  static const Curve scaleCurve = curveStandard;
  
  /// Slide animation preset
  static const Duration slideDuration = durationMedium;
  static const Curve slideCurve = curveDecelerate;
  
  /// Button press animation
  static const Duration buttonPressDuration = durationXs;
  static const Curve buttonPressCurve = curveStandard;
  
  /// Container expand/collapse
  static const Duration expandDuration = durationMedium;
  static const Curve expandCurve = curveEmphasized;
  
  /// Bottom sheet animation
  static const Duration bottomSheetDuration = durationMedium;
  static const Curve bottomSheetCurve = curveDecelerate;
  
  /// Dialog animation
  static const Duration dialogDuration = durationFast;
  static const Curve dialogCurve = curveDecelerate;
  
  /// Snackbar animation
  static const Duration snackBarDuration = durationFast;
  static const Curve snackBarCurve = curveDecelerate;
}

/// ThemeExtension for accessing motion via Theme.of(context)
class AppMotionTheme extends ThemeExtension<AppMotionTheme> {
  final Duration durationXs;
  final Duration durationSm;
  final Duration durationFast;
  final Duration durationMedium;
  final Duration durationSlow;
  final Duration durationXl;
  final Curve curveStandard;
  final Curve curveEmphasized;
  final Curve curveDecelerate;
  final Curve curveAccelerate;

  const AppMotionTheme({
    this.durationXs = const Duration(milliseconds: 50),
    this.durationSm = const Duration(milliseconds: 100),
    this.durationFast = const Duration(milliseconds: 200),
    this.durationMedium = const Duration(milliseconds: 300),
    this.durationSlow = const Duration(milliseconds: 400),
    this.durationXl = const Duration(milliseconds: 500),
    this.curveStandard = Curves.easeOutCubic,
    this.curveEmphasized = Curves.easeInOutCubic,
    this.curveDecelerate = Curves.easeOutQuart,
    this.curveAccelerate = Curves.easeInQuart,
  });

  @override
  AppMotionTheme copyWith({
    Duration? durationXs,
    Duration? durationSm,
    Duration? durationFast,
    Duration? durationMedium,
    Duration? durationSlow,
    Duration? durationXl,
    Curve? curveStandard,
    Curve? curveEmphasized,
    Curve? curveDecelerate,
    Curve? curveAccelerate,
  }) {
    return AppMotionTheme(
      durationXs: durationXs ?? this.durationXs,
      durationSm: durationSm ?? this.durationSm,
      durationFast: durationFast ?? this.durationFast,
      durationMedium: durationMedium ?? this.durationMedium,
      durationSlow: durationSlow ?? this.durationSlow,
      durationXl: durationXl ?? this.durationXl,
      curveStandard: curveStandard ?? this.curveStandard,
      curveEmphasized: curveEmphasized ?? this.curveEmphasized,
      curveDecelerate: curveDecelerate ?? this.curveDecelerate,
      curveAccelerate: curveAccelerate ?? this.curveAccelerate,
    );
  }

  @override
  AppMotionTheme lerp(ThemeExtension<AppMotionTheme>? other, double t) {
    // Durations and curves can't be interpolated meaningfully
    // Return target after halfway point
    if (other is! AppMotionTheme) return this;
    return t < 0.5 ? this : other;
  }
}

/// Convenience extension on BuildContext for easy motion access
extension MotionExtension on BuildContext {
  /// Access motion theme extension
  AppMotionTheme get motion =>
      Theme.of(this).extension<AppMotionTheme>() ?? const AppMotionTheme();
}
