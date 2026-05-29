import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ingredio/di/service_locator.dart';

const _themeModePreferenceKey = 'theme_mode';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(getIt<SharedPreferences>());
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeModeNotifier(this._prefs) : super(_loadInitialMode(_prefs));

  static ThemeMode _loadInitialMode(SharedPreferences prefs) {
    final stored = prefs.getString(_themeModePreferenceKey);
    switch (stored) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_themeModePreferenceKey, mode.name);
  }

  Future<void> setDarkMode(bool isDark) {
    return setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
