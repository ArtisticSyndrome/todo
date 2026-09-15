import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/storage/storage_service.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/tasks/data/task_repository.dart';
import 'features/tasks/presentation/providers/task_provider.dart';

void main() {
  final storage = StorageService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider(TaskRepository(storage))..load()),
        ChangeNotifierProvider(
            create: (_) => SettingsProvider(SettingsRepository(storage))..load()),
      ],
      child: const TodoApp(),
    ),
  );
}
