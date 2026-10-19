import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  static const String _themeModeKey = 'theme_mode';

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getInt(_themeModeKey);
      if (index != null && index >= 0 && index < ThemeMode.values.length) {
        state = ThemeMode.values[index];
      }
    } catch (_) {
      // Ignore errors, keep default
    }
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
    } catch (_) {
      // Ignore errors
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _saveThemeMode(mode);
  }

  void toggleBrightness() {
    if (state == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      // ThemeMode.system -> switch to light
      setThemeMode(ThemeMode.light);
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier();
});
