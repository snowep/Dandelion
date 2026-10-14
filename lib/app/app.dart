import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_router.dart';

class DandelionApp extends StatelessWidget {
  const DandelionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dandelion',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
