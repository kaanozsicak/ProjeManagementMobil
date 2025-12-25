import 'package:flutter/material.dart';

/// Design system color palette.
/// 
/// Modern, vibrant yet clean color system for "Kim Ne Yaptı?" app.
/// Uses a harmonious palette with semantic colors.
abstract final class AppColors {
  // ============================================
  // Primary Brand Colors
  // ============================================
  
  /// Primary brand color - Deep violet/purple
  static const Color primary = Color(0xFF7C4DFF);
  
  /// Primary light variant
  static const Color primaryLight = Color(0xFFB47CFF);
  
  /// Primary dark variant
  static const Color primaryDark = Color(0xFF5C35CC);
  
  /// Primary container (for backgrounds)
  static const Color primaryContainer = Color(0xFFEDE7FF);
  static const Color primaryContainerDark = Color(0xFF2D1F5E);
  
  // ============================================
  // Secondary Colors - Teal/Cyan
  // ============================================
  
  /// Secondary color - Vibrant teal
  static const Color secondary = Color(0xFF00BFA5);
  
  /// Secondary light variant
  static const Color secondaryLight = Color(0xFF5DF2D6);
  
  /// Secondary dark variant
  static const Color secondaryDark = Color(0xFF008E76);
  
  /// Secondary container
  static const Color secondaryContainer = Color(0xFFCCF5EE);
  static const Color secondaryContainerDark = Color(0xFF004D40);
  
  // ============================================
  // Tertiary Colors - Warm Orange
  // ============================================
  
  /// Tertiary color - Warm coral/orange
  static const Color tertiary = Color(0xFFFF7043);
  
  /// Tertiary light variant
  static const Color tertiaryLight = Color(0xFFFFAB91);
  
  /// Tertiary dark variant
  static const Color tertiaryDark = Color(0xFFE64A19);
  
  /// Tertiary container
  static const Color tertiaryContainer = Color(0xFFFFE0D6);
  static const Color tertiaryContainerDark = Color(0xFF5D2715);
  
  // ============================================
  // Semantic Colors
  // ============================================
  
  /// Success - Green
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color successContainerDark = Color(0xFF1B5E20);
  
  /// Warning - Amber
  static const Color warning = Color(0xFFFFB300);
  static const Color warningLight = Color(0xFFFFD54F);
  static const Color warningDark = Color(0xFFFFA000);
  static const Color warningContainer = Color(0xFFFFF8E1);
  static const Color warningContainerDark = Color(0xFF664400);
  
  /// Error - Red
  static const Color error = Color(0xFFEF5350);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color errorContainerDark = Color(0xFF5D1F1F);
  
  /// Info - Blue
  static const Color info = Color(0xFF29B6F6);
  static const Color infoLight = Color(0xFF4FC3F7);
  static const Color infoDark = Color(0xFF0288D1);
  static const Color infoContainer = Color(0xFFE1F5FE);
  static const Color infoContainerDark = Color(0xFF01579B);
  
  // ============================================
  // State Colors (for item states)
  // ============================================
  
  /// Todo state - Soft blue-gray (lighter for dark mode readability)
  static const Color stateTodo = Color(0xFF90A4AE);
  static const Color stateTodoContainer = Color(0xFFECEFF1);
  static const Color stateTodoContainerDark = Color(0xFF37474F);
  
  /// Doing state - Vibrant blue
  static const Color stateDoing = Color(0xFF42A5F5);
  static const Color stateDoingContainer = Color(0xFFE3F2FD);
  static const Color stateDoingContainerDark = Color(0xFF0D47A1);
  
  /// Done state - Success green
  static const Color stateDone = Color(0xFF81C784);
  static const Color stateDoneContainer = Color(0xFFE8F5E9);
  static const Color stateDoneContainerDark = Color(0xFF2E7D32);
  
  // ============================================
  // Item Type Colors
  // ============================================
  
  /// Active task - Primary purple
  static const Color typeActive = Color(0xFF7C4DFF);
  static const Color typeActiveContainer = Color(0xFFEDE7FF);
  static const Color typeActiveContainerDark = Color(0xFF2D1F5E);
  
  /// Bug - Red
  static const Color typeBug = Color(0xFFF44336);
  static const Color typeBugContainer = Color(0xFFFFEBEE);
  static const Color typeBugContainerDark = Color(0xFF5D1F1F);
  
  /// Logic - Orange
  static const Color typeLogic = Color(0xFFFF9800);
  static const Color typeLogicContainer = Color(0xFFFFF3E0);
  static const Color typeLogicContainerDark = Color(0xFF5D3A00);
  
  /// Idea - Cyan/teal
  static const Color typeIdea = Color(0xFF00BCD4);
  static const Color typeIdeaContainer = Color(0xFFE0F7FA);
  static const Color typeIdeaContainerDark = Color(0xFF006064);
  
  // ============================================
  // Priority Colors
  // ============================================
  
  /// Low priority - Gray/neutral (brighter for dark mode)
  static const Color priorityLow = Color(0xFFBDBDBD);
  static const Color priorityLowContainer = Color(0xFFF5F5F5);
  static const Color priorityLowContainerDark = Color(0xFF525252);
  
  /// Medium priority - Amber (brighter)
  static const Color priorityMedium = Color(0xFFFFD54F);
  static const Color priorityMediumContainer = Color(0xFFFFF8E1);
  static const Color priorityMediumContainerDark = Color(0xFF6D5A00);
  
  /// High priority - Red (brighter)
  static const Color priorityHigh = Color(0xFFFF6B6B);
  static const Color priorityHighContainer = Color(0xFFFFEBEE);
  static const Color priorityHighContainerDark = Color(0xFF6D2F2F);
  
  // ============================================
  // Presence Status Colors (consistent across light/dark modes)
  // ============================================
  
  /// Boşta - Gray
  static const Color presenceIdle = Color(0xFF9E9E9E);
  /// Aktif - Green
  static const Color presenceActive = Color(0xFF4CAF50);
  /// Meşgul - Red
  static const Color presenceBusy = Color(0xFFF44336);
  /// Uzakta - Yellow/Amber
  static const Color presenceAway = Color(0xFFFFB300);
  
  // ============================================
  // Surface Colors (Light)
  // ============================================
  
  /// Light mode surfaces
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDimLight = Color(0xFFF0F0F0);
  static const Color surfaceBrightLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowestLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowLight = Color(0xFFF5F5F5);
  static const Color surfaceContainerLight = Color(0xFFEEEEEE);
  static const Color surfaceContainerHighLight = Color(0xFFE0E0E0);
  static const Color surfaceContainerHighestLight = Color(0xFFD6D6D6);
  
  // ============================================
  // Surface Colors (Dark)
  // ============================================
  
  /// Dark mode surfaces - Deep, rich dark with subtle warmth
  static const Color surfaceDark = Color(0xFF121218);
  static const Color surfaceDimDark = Color(0xFF0D0D12);
  static const Color surfaceBrightDark = Color(0xFF1E1E26);
  static const Color surfaceContainerLowestDark = Color(0xFF0A0A0F);
  static const Color surfaceContainerLowDark = Color(0xFF151519);
  static const Color surfaceContainerDark = Color(0xFF1A1A22);
  static const Color surfaceContainerHighDark = Color(0xFF242430);
  static const Color surfaceContainerHighestDark = Color(0xFF2E2E3A);
  
  // ============================================
  // Text Colors
  // ============================================
  
  /// Light mode text
  static const Color onSurfaceLight = Color(0xFF1A1A1A);
  static const Color onSurfaceVariantLight = Color(0xFF5C5C5C);
  static const Color outlineLight = Color(0xFFBDBDBD);
  static const Color outlineVariantLight = Color(0xFFE0E0E0);
  
  /// Dark mode text - Higher contrast for better readability
  static const Color onSurfaceDark = Color(0xFFF8F8F8);
  static const Color onSurfaceVariantDark = Color(0xFFE0E0E0);
  static const Color outlineDark = Color(0xFFB0B0B0);
  static const Color outlineVariantDark = Color(0xFF606060);
  
  // ============================================
  // Gradient Presets
  // ============================================
  
  /// Primary gradient (purple)
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFFB47CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Secondary gradient (teal)
  static const LinearGradient gradientSecondary = LinearGradient(
    colors: [Color(0xFF00BFA5), Color(0xFF5DF2D6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Tertiary gradient (orange)
  static const LinearGradient gradientTertiary = LinearGradient(
    colors: [Color(0xFFFF7043), Color(0xFFFFAB91)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Accent gradient (multi-color)
  static const LinearGradient gradientAccent = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Warm gradient (for highlights)
  static const LinearGradient gradientWarm = LinearGradient(
    colors: [Color(0xFFFF7043), Color(0xFFFFB300)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Cool gradient (for calm elements)
  static const LinearGradient gradientCool = LinearGradient(
    colors: [Color(0xFF29B6F6), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Dark mode background gradient
  static const LinearGradient gradientDarkBackground = LinearGradient(
    colors: [Color(0xFF121218), Color(0xFF1A1A22)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  /// Card gradient for dark mode
  static const LinearGradient gradientDarkCard = LinearGradient(
    colors: [Color(0xFF1E1E26), Color(0xFF242430)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ============================================
  // Helper Methods
  // ============================================
  
  /// Get color for item type
  static Color getTypeColor(String type) {
    switch (type) {
      case 'activeTask':
        return typeActive;
      case 'bug':
        return typeBug;
      case 'logic':
        return typeLogic;
      case 'idea':
        return typeIdea;
      default:
        return primary;
    }
  }
  
  /// Get container color for item type
  static Color getTypeContainerColor(String type, {bool isDark = false}) {
    switch (type) {
      case 'activeTask':
        return isDark ? typeActiveContainerDark : typeActiveContainer;
      case 'bug':
        return isDark ? typeBugContainerDark : typeBugContainer;
      case 'logic':
        return isDark ? typeLogicContainerDark : typeLogicContainer;
      case 'idea':
        return isDark ? typeIdeaContainerDark : typeIdeaContainer;
      default:
        return isDark ? primaryContainerDark : primaryContainer;
    }
  }
  
  /// Get color for item state
  static Color getStateColor(String state) {
    switch (state) {
      case 'todo':
        return stateTodo;
      case 'doing':
        return stateDoing;
      case 'done':
        return stateDone;
      default:
        return stateTodo;
    }
  }
  
  /// Get color for priority
  static Color getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return priorityLow;
      case 'medium':
        return priorityMedium;
      case 'high':
        return priorityHigh;
      default:
        return priorityMedium;
    }
  }
  
  /// Get color for presence status
  static Color getPresenceColor(String status) {
    switch (status) {
      case 'idle':
        return presenceIdle;
      case 'active':
        return presenceActive;
      case 'busy':
        return presenceBusy;
      case 'away':
        return presenceAway;
      default:
        return presenceIdle;
    }
  }
}

/// Extension for easy access to semantic colors
extension ColorSchemeExtension on ColorScheme {
  /// Success color
  Color get success => brightness == Brightness.dark 
      ? AppColors.successLight 
      : AppColors.success;
  
  /// Success container
  Color get successContainer => brightness == Brightness.dark
      ? AppColors.successContainerDark
      : AppColors.successContainer;
  
  /// Warning color
  Color get warning => brightness == Brightness.dark
      ? AppColors.warningLight
      : AppColors.warning;
  
  /// Warning container
  Color get warningContainer => brightness == Brightness.dark
      ? AppColors.warningContainerDark
      : AppColors.warningContainer;
  
  /// Info color
  Color get info => brightness == Brightness.dark
      ? AppColors.infoLight
      : AppColors.info;
  
  /// Info container
  Color get infoContainer => brightness == Brightness.dark
      ? AppColors.infoContainerDark
      : AppColors.infoContainer;
}
