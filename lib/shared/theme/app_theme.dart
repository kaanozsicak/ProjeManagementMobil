import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_spacing.dart';
import 'app_motion.dart';
import 'app_colors.dart';

/// Application theme configuration.
/// 
/// Provides Material Design 3 compliant themes with modern,
/// vibrant, and clean aesthetics for the "Kim Ne Yaptı?" app.
/// 
/// Features:
/// - Light & Dark mode with carefully crafted palettes
/// - Vibrant accent colors with semantic meaning
/// - Clean, minimal design with subtle depth
/// - Smooth transitions and micro-interactions
abstract final class AppTheme {
  // ============================================
  // Brand Colors (Exposed for direct access)
  // ============================================
  
  /// Primary seed color - Vibrant purple
  static const Color seedColor = AppColors.primary;
  
  /// Secondary accent - Teal
  static const Color accentColor = AppColors.secondary;
  
  /// Tertiary accent - Coral orange
  static const Color tertiaryColor = AppColors.tertiary;

  // ============================================
  // Border Radius Scale
  // ============================================
  
  static const double radiusXs = 8.0;
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;
  static const double radiusXxl = 32.0;
  static const double radiusFull = 9999.0;

  // ============================================
  // Elevation Scale
  // ============================================
  
  static const double elevationNone = 0.0;
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 12.0;

  // ============================================
  // Light Theme
  // ============================================
  
  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      // Primary
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primaryDark,
      // Secondary
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.secondaryDark,
      // Tertiary
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.tertiaryDark,
      // Error
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.errorDark,
      // Surface
      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
      onSurfaceVariant: AppColors.onSurfaceVariantLight,
      // Outline
      outline: AppColors.outlineLight,
      outlineVariant: AppColors.outlineVariantLight,
      // Shadow & Scrim
      shadow: Colors.black,
      scrim: Colors.black,
      // Inverse
      inverseSurface: AppColors.surfaceDark,
      onInverseSurface: AppColors.onSurfaceDark,
      inversePrimary: AppColors.primaryLight,
      // Surface variants
      surfaceDim: AppColors.surfaceDimLight,
      surfaceBright: AppColors.surfaceBrightLight,
      surfaceContainerLowest: AppColors.surfaceContainerLowestLight,
      surfaceContainerLow: AppColors.surfaceContainerLowLight,
      surfaceContainer: AppColors.surfaceContainerLight,
      surfaceContainerHigh: AppColors.surfaceContainerHighLight,
      surfaceContainerHighest: AppColors.surfaceContainerHighestLight,
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  // ============================================
  // Dark Theme
  // ============================================
  
  static ThemeData get dark {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      // Primary - Lighter for dark mode
      primary: AppColors.primaryLight,
      onPrimary: AppColors.primaryDark,
      primaryContainer: AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.primaryLight,
      // Secondary
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.secondaryDark,
      secondaryContainer: AppColors.secondaryContainerDark,
      onSecondaryContainer: AppColors.secondaryLight,
      // Tertiary
      tertiary: AppColors.tertiaryLight,
      onTertiary: AppColors.tertiaryDark,
      tertiaryContainer: AppColors.tertiaryContainerDark,
      onTertiaryContainer: AppColors.tertiaryLight,
      // Error
      error: AppColors.errorLight,
      onError: AppColors.errorDark,
      errorContainer: AppColors.errorContainerDark,
      onErrorContainer: AppColors.errorLight,
      // Surface - Rich dark tones
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,
      // Outline
      outline: AppColors.outlineDark,
      outlineVariant: AppColors.outlineVariantDark,
      // Shadow & Scrim
      shadow: Colors.black,
      scrim: Colors.black,
      // Inverse
      inverseSurface: AppColors.surfaceLight,
      onInverseSurface: AppColors.onSurfaceLight,
      inversePrimary: AppColors.primary,
      // Surface variants
      surfaceDim: AppColors.surfaceDimDark,
      surfaceBright: AppColors.surfaceBrightDark,
      surfaceContainerLowest: AppColors.surfaceContainerLowestDark,
      surfaceContainerLow: AppColors.surfaceContainerLowDark,
      surfaceContainer: AppColors.surfaceContainerDark,
      surfaceContainerHigh: AppColors.surfaceContainerHighDark,
      surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  // ============================================
  // Theme Builder
  // ============================================
  
  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      
      // Extensions
      extensions: const [
        AppSpacingTheme(),
        AppMotionTheme(),
      ],

      // ----------------------------------------
      // Scaffold
      // ----------------------------------------
      scaffoldBackgroundColor: colorScheme.surface,

      // ----------------------------------------
      // Typography
      // ----------------------------------------
      textTheme: _buildTextTheme(colorScheme),
      
      // ----------------------------------------
      // AppBar - Clean with subtle accent
      // ----------------------------------------
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: elevationNone,
        scrolledUnderElevation: elevationSm,
        backgroundColor: isDark 
            ? colorScheme.surface 
            : colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.primary.withOpacity(0.05),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: colorScheme.surface,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: colorScheme.surface,
              ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: colorScheme.primary,
          size: 24,
        ),
      ),

      // ----------------------------------------
      // Card - Subtle elevation with accent tint
      // ----------------------------------------
      cardTheme: CardTheme(
        elevation: isDark ? elevationXs : elevationSm,
        shadowColor: isDark 
            ? Colors.black.withOpacity(0.3) 
            : colorScheme.shadow.withOpacity(0.08),
        surfaceTintColor: colorScheme.primary.withOpacity(0.02),
        color: isDark 
            ? colorScheme.surfaceContainerLow 
            : colorScheme.surfaceBright,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: isDark 
              ? BorderSide(color: colorScheme.outlineVariant.withOpacity(0.1))
              : BorderSide.none,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ----------------------------------------
      // Chip - Colorful and modern
      // ----------------------------------------
      chipTheme: ChipThemeData(
        elevation: elevationNone,
        pressElevation: elevationXs,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
        backgroundColor: colorScheme.surfaceContainerHigh,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimaryContainer,
        ),
        side: BorderSide.none,
        showCheckmark: false,
      ),

      // ----------------------------------------
      // Input Decoration - Modern with accent focus
      // ----------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerHigh.withOpacity(0.5)
            : colorScheme.surfaceContainerHighest.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
      ),

      // ----------------------------------------
      // Dialog - Clean with subtle depth
      // ----------------------------------------
      dialogTheme: DialogTheme(
        elevation: elevationLg,
        shadowColor: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
        surfaceTintColor: colorScheme.primary.withOpacity(0.03),
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.2,
        ),
        contentTextStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
      ),

      // ----------------------------------------
      // Bottom Sheet - Modern with handle
      // ----------------------------------------
      bottomSheetTheme: BottomSheetThemeData(
        elevation: elevationLg,
        shadowColor: Colors.black.withOpacity(isDark ? 0.5 : 0.2),
        surfaceTintColor: colorScheme.primary.withOpacity(0.02),
        modalElevation: elevationXl,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXxl)),
        ),
        showDragHandle: true,
        dragHandleColor: colorScheme.outline.withOpacity(0.3),
        dragHandleSize: const Size(40, 4),
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
        constraints: const BoxConstraints(maxWidth: 640),
      ),

      // ----------------------------------------
      // SnackBar - Vibrant and noticeable
      // ----------------------------------------
      snackBarTheme: SnackBarThemeData(
        elevation: elevationMd,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        backgroundColor: isDark 
            ? colorScheme.surfaceContainerHighest
            : colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? colorScheme.onSurface : colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.primary,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),

      // ----------------------------------------
      // Elevated Button - Primary with depth
      // ----------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: elevationSm,
          shadowColor: colorScheme.primary.withOpacity(0.3),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm + 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          minimumSize: const Size(80, 48),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return elevationXs;
            if (states.contains(WidgetState.hovered)) return elevationMd;
            if (states.contains(WidgetState.disabled)) return elevationNone;
            return elevationSm;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.12);
            }
            return colorScheme.primary;
          }),
        ),
      ),

      // ----------------------------------------
      // Filled Button - Prominent action
      // ----------------------------------------
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm + 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          minimumSize: const Size(80, 48),
        ),
      ),

      // ----------------------------------------
      // Outlined Button - Secondary action
      // ----------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm + 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          minimumSize: const Size(80, 48),
        ),
      ),

      // ----------------------------------------
      // Text Button - Tertiary action
      // ----------------------------------------
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          minimumSize: const Size(64, 40),
        ),
      ),

      // ----------------------------------------
      // Icon Button
      // ----------------------------------------
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          padding: const EdgeInsets.all(AppSpacing.xs),
        ),
      ),

      // ----------------------------------------
      // Floating Action Button - Vibrant
      // ----------------------------------------
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: elevationMd,
        focusElevation: elevationLg,
        hoverElevation: elevationLg,
        highlightElevation: elevationSm,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        extendedTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),

      // ----------------------------------------
      // List Tile
      // ----------------------------------------
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        horizontalTitleGap: AppSpacing.md,
        minVerticalPadding: AppSpacing.xs,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
        iconColor: colorScheme.onSurfaceVariant,
        selectedColor: colorScheme.primary,
        selectedTileColor: colorScheme.primaryContainer.withOpacity(0.5),
      ),

      // ----------------------------------------
      // Divider
      // ----------------------------------------
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withOpacity(isDark ? 0.3 : 0.5),
        thickness: 1,
        space: AppSpacing.md,
      ),

      // ----------------------------------------
      // PopupMenu
      // ----------------------------------------
      popupMenuTheme: PopupMenuThemeData(
        elevation: elevationMd,
        shadowColor: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
        surfaceTintColor: colorScheme.primary.withOpacity(0.03),
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          side: isDark 
              ? BorderSide(color: colorScheme.outlineVariant.withOpacity(0.1))
              : BorderSide.none,
        ),
      ),

      // ----------------------------------------
      // Tooltip
      // ----------------------------------------
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(radiusXs),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        textStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onInverseSurface,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),

      // ----------------------------------------
      // Switch - Colorful
      // ----------------------------------------
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return colorScheme.outline.withOpacity(0.5);
        }),
      ),

      // ----------------------------------------
      // Checkbox - Rounded and colorful
      // ----------------------------------------
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        side: BorderSide(color: colorScheme.outline, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
      ),

      // ----------------------------------------
      // Radio
      // ----------------------------------------
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
      ),

      // ----------------------------------------
      // Progress Indicator - Vibrant
      // ----------------------------------------
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer.withOpacity(0.3),
        circularTrackColor: colorScheme.primaryContainer.withOpacity(0.3),
      ),

      // ----------------------------------------
      // Drawer
      // ----------------------------------------
      drawerTheme: DrawerThemeData(
        elevation: elevationLg,
        shadowColor: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
        surfaceTintColor: colorScheme.primary.withOpacity(0.02),
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(radiusMd)),
        ),
      ),

      // ----------------------------------------
      // Navigation Bar (Bottom)
      // ----------------------------------------
      navigationBarTheme: NavigationBarThemeData(
        elevation: elevationNone,
        height: 72,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.primary.withOpacity(0.03),
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            size: 24,
          );
        }),
      ),

      // ----------------------------------------
      // Navigation Rail
      // ----------------------------------------
      navigationRailTheme: NavigationRailThemeData(
        elevation: elevationNone,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelType: NavigationRailLabelType.all,
        selectedLabelTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),

      // ----------------------------------------
      // Tab Bar - Clean with accent indicator
      // ----------------------------------------
      tabBarTheme: TabBarTheme(
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.primary,
              width: 3,
            ),
          ),
        ),
        indicatorColor: colorScheme.primary,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: colorScheme.outlineVariant.withOpacity(0.3),
        overlayColor: WidgetStateProperty.all(
          colorScheme.primary.withOpacity(0.1),
        ),
      ),

      // ----------------------------------------
      // Badge
      // ----------------------------------------
      badgeTheme: BadgeThemeData(
        backgroundColor: colorScheme.error,
        textColor: colorScheme.onError,
        smallSize: 8,
        largeSize: 18,
        textStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 5),
      ),

      // ----------------------------------------
      // Search Bar
      // ----------------------------------------
      searchBarTheme: SearchBarThemeData(
        elevation: WidgetStateProperty.all(elevationNone),
        backgroundColor: WidgetStateProperty.all(
          colorScheme.surfaceContainerHighest.withOpacity(isDark ? 0.5 : 0.7),
        ),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
            side: BorderSide(
              color: colorScheme.outline.withOpacity(0.1),
            ),
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        textStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
          ),
        ),
        hintStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      ),

      // ----------------------------------------
      // Segmented Button
      // ----------------------------------------
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSm),
            ),
          ),
          side: WidgetStateProperty.all(
            BorderSide(color: colorScheme.outline.withOpacity(0.5)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primaryContainer;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return colorScheme.onSurfaceVariant;
          }),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),

      // ----------------------------------------
      // Date/Time Pickers - Colorful headers
      // ----------------------------------------
      datePickerTheme: DatePickerThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        backgroundColor: colorScheme.surface,
        headerBackgroundColor: colorScheme.primaryContainer,
        headerForegroundColor: colorScheme.onPrimaryContainer,
        dayShape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXs),
          ),
        ),
        todayBorder: BorderSide(color: colorScheme.primary, width: 2),
        rangeSelectionBackgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
      ),
      
      timePickerTheme: TimePickerThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        backgroundColor: colorScheme.surface,
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        dialBackgroundColor: colorScheme.surfaceContainerHighest,
      ),

      // ----------------------------------------
      // Slider
      // ----------------------------------------
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primaryContainer.withOpacity(0.5),
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withOpacity(0.12),
        valueIndicatorColor: colorScheme.primary,
        valueIndicatorTextStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================
  // Text Theme
  // ============================================
  
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.5,
        height: 1.12,
        color: colorScheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.16,
        color: colorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
        color: colorScheme.onSurface,
      ),
      
      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.25,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.15,
        height: 1.29,
        color: colorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
        color: colorScheme.onSurface,
      ),
      
      // Title styles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.27,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.5,
        color: colorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: colorScheme.onSurface,
      ),
      
      // Body styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        height: 1.5,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.43,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        height: 1.33,
        color: colorScheme.onSurfaceVariant,
      ),
      
      // Label styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        height: 1.33,
        color: colorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        height: 1.45,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
