import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_shell.dart';

class DandelionApp extends StatelessWidget {
  const DandelionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dandelion',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AppShell(),
    );
  }
}
