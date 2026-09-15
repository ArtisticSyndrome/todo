import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/tasks/presentation/screens/home_screen.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().settings.isDark;

    return MaterialApp(
      title: 'Todo',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
      supportedLocales: FlutterQuillLocalizations.supportedLocales,
      theme: isDark ? AppTheme.dark : AppTheme.light,
      // Theme swaps animate smoothly instead of snapping instantly.
      builder: (context, child) => AnimatedTheme(
        data: isDark ? AppTheme.dark : AppTheme.light,
        duration: const Duration(milliseconds: 300),
        child: child!,
      ),
      home: const HomeScreen(),
    );
  }
}
