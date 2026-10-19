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
    notifier.setThemeMode(ThemeMode.light);
    notifier.toggleBrightness();
    expect(notifier.state, ThemeMode.dark);

    notifier.toggleBrightness();
    expect(notifier.state, ThemeMode.light);
  });

  test('toggle from system goes to light', () {
    notifier.setThemeMode(ThemeMode.system);
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
