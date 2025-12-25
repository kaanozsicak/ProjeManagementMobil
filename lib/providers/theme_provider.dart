import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode preference key
const _themeModeKey = 'theme_mode';

/// Theme mode state notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences? _prefs;
  
  ThemeModeNotifier(this._prefs) : super(_loadThemeMode(_prefs));
  
  static ThemeMode _loadThemeMode(SharedPreferences? prefs) {
    final value = prefs?.getString(_themeModeKey);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
  
  /// Set theme mode and persist
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs?.setString(_themeModeKey, mode.name);
  }
  
  /// Toggle between light and dark (skips system)
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
  
  /// Cycle through all modes: system -> light -> dark -> system
  Future<void> cycleThemeMode() async {
    final newMode = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(newMode);
  }
  
  /// Check if currently dark
  bool get isDark => state == ThemeMode.dark;
  
  /// Check if following system
  bool get isSystem => state == ThemeMode.system;
}

/// Shared preferences provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Theme mode notifier provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefsAsync.valueOrNull);
});

/// Helper extension for getting theme mode icon
extension ThemeModeExtension on ThemeMode {
  IconData get icon {
    switch (this) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }
  
  String get label {
    switch (this) {
      case ThemeMode.light:
        return 'Açık Tema';
      case ThemeMode.dark:
        return 'Koyu Tema';
      case ThemeMode.system:
        return 'Sistem';
    }
  }
}
