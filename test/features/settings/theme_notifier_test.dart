import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dandelion/features/settings/theme_notifier.dart';

void main() {
  late ThemeModeNotifier notifier;

  setUp(() {
    notifier = ThemeModeNotifier();
  });

  test('initial theme is system', () {
    expect(notifier.state, ThemeMode.system);
  });

  test('toggle brightness changes theme correctly', () {
    // Starting from system, toggle to light (assuming system is not light or dark? Actually, we don't know what system resolves to.
    // Instead, we test the toggle logic: light <-> dark, and system toggles to light? Actually, the toggleBrightness method only toggles between light and dark.
    // If the current state is system, it will go to dark (because system == light? false, so it goes to dark).
    // We'll test by setting a known state first.
    notifier.setThemeMode(ThemeMode.light);
    notifier.toggleBrightness();
    expect(notifier.state, ThemeMode.dark);

    notifier.toggleBrightness();
    expect(notifier.state, ThemeMode.light);
  });

  test('setThemeMode updates state', () {
    notifier.setThemeMode(ThemeMode.dark);
    expect(notifier.state, ThemeMode.dark);
    notifier.setThemeMode(ThemeMode.light);
    expect(notifier.state, ThemeMode.light);
    notifier.setThemeMode(ThemeMode.system);
    expect(notifier.state, ThemeMode.system);
  });
}
